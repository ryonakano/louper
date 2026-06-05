/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "main-window.h"

#include <granite-7/granite-7.h>

struct _LouperMainWindow {
    GtkApplicationWindow            parent_instance;

    gboolean                        keep_open;
    const GString                   *text;
    gboolean                        is_label_updated;
    guint                           destroy_timeout_id;
};

G_DEFINE_FINAL_TYPE (LouperMainWindow, louper_main_window, GTK_TYPE_APPLICATION_WINDOW)

#define CSS_DATA        ".magnified-text {" \
                        "    font-size: 128px;" \
                        "    font-weight: bold;" \
                        "}"

static void
calculate_size (LouperMainWindow    *self,
                GdkDisplay          *display)
{
    // Can't use g_autoptr() because GdkSurface instances need to be destroyed instead of just unref
    /* gobject-linter-ignore-next-line: use_auto_cleanup */
    GdkSurface *surface;
    GdkMonitor *primary_monitor;
    GdkRectangle primary_monitor_rectangle;
    int width;
    int height;

    // Get the area where we can draw the app window
    surface = gdk_surface_new_toplevel (display);
    primary_monitor = gdk_display_get_monitor_at_surface (display, surface);
    if (!primary_monitor) {
        g_warning ("Failed to gdk_display_get_monitor_at_surface()");
        goto destroy_surface;
    }

    gdk_monitor_get_geometry (primary_monitor, &primary_monitor_rectangle);

    // Set reasonable window size
    width = primary_monitor_rectangle.width / 2;
    height = primary_monitor_rectangle.height / 4;
    gtk_window_set_default_size (GTK_WINDOW (self), width, height);

destroy_surface:
    gdk_surface_destroy (surface);
}

static void
read_text_cb (GObject       *source_object,
              GAsyncResult  *res,
              gpointer       data)
{
    GdkClipboard *clipboard;
    GtkLabel *label;
    g_autofree char *text;
    g_autoptr(GError) err = NULL;

    clipboard = GDK_CLIPBOARD (source_object);
    label = GTK_LABEL (data);

    text = gdk_clipboard_read_text_finish (clipboard, res, &err);
    if (err) {
        g_warning ("Failed to read text from clipboard: %s", err->message);
        return;
    }

    gtk_label_set_label (label, text);
}

static void
load_clipboard (LouperMainWindow      *self,
                GtkLabel              *label_widget)
{
    GdkClipboard *clipboard;

    clipboard = gtk_widget_get_primary_clipboard (GTK_WIDGET (self));

    gdk_clipboard_read_text_async (clipboard, NULL, read_text_cb, label_widget);
}

static void
update_label_text (LouperMainWindow     *self,
                   GtkLabel             *label_widget)
{
    if (self->text) {
        // Set the text passed by the command line option if specified
        gtk_label_set_label (label_widget, self->text->str);
    } else {
        // Otherwise set the text loaded from clipboard
        load_clipboard (self, label_widget);
    }
}

static void
notify_is_active_cb (GtkWindow     *window,
                     GParamSpec    *pspec,
                     gpointer       user_data)
{
    LouperMainWindow *self;
    GtkLabel *magnified_label;
    gboolean is_active;

    (void) pspec;

    self = LOUPER_MAIN_WINDOW (window);
    magnified_label = GTK_LABEL (user_data);

    is_active = gtk_window_is_active (window);
    if (!is_active) {
        // Do nothing when the window lost focus.
        // NOTE: We don't close the window here because is-active gets false also when opening the context menu.
        // We handle it in state_flags_changed instead so that users can use the context menu.
        return;
    }

    if (self->is_label_updated) {
        // Do nothing if the label text is already set.
        return;
    }

    self->is_label_updated = TRUE;

    // When the window get focused, update the label with the specified text or clipboard content.
    // NOTE: The reason to update the label after the window get focused is that
    // getting clipboard content is not allowed until that happens on Wayland.
    // See https://gitlab.gnome.org/GNOME/gtk/-/issues/1874#note_509304
    update_label_text (self, magnified_label);
}

static void
louper_main_window_state_flags_changed (GtkWidget       *widget,
                                        GtkStateFlags    previous_state_flags)
{
    LouperMainWindow *self;
    GtkStateFlags current_state_flags;

    (void) previous_state_flags;

    self = LOUPER_MAIN_WINDOW (widget);

    current_state_flags = gtk_widget_get_state_flags (widget);
    if (current_state_flags & GTK_STATE_FLAG_BACKDROP) {
        if (self->keep_open) {
            return;
        }

        // Hide first and then destroy the app window when unfocused
        // because just destroying sometimes seems to cause the wm crashing.
        // Borrowed from shortcut-overlay by elementary.
        gtk_widget_set_visible (widget, FALSE);
        self->destroy_timeout_id = g_timeout_add_once (250, (GSourceOnceFunc) gtk_window_destroy, GTK_WINDOW (widget));
    }
}

static void
louper_main_window_dispose (GObject *object)
{
    LouperMainWindow *self;

    self = LOUPER_MAIN_WINDOW (object);

    if (self->destroy_timeout_id > 0) {
        // Clear destroy timeout to avoid use-after-free of a MainWindow instance
        g_clear_handle_id (&(self->destroy_timeout_id), g_source_remove);

        // No need to set self->destroy_timeout_id to 0 here; g_clear_handle_id() already did
    }

    G_OBJECT_CLASS (louper_main_window_parent_class)->dispose (object);
}

static void
louper_main_window_class_init (LouperMainWindowClass *klass)
{
    GtkWidgetClass *widget_class;
    GObjectClass *object_class;

    widget_class = GTK_WIDGET_CLASS (klass);
    object_class = G_OBJECT_CLASS (klass);

    widget_class->state_flags_changed = louper_main_window_state_flags_changed;

    object_class->dispose = louper_main_window_dispose;
}

static void
louper_main_window_init (LouperMainWindow *self)
{
    GtkWindow *window;
    GdkDisplay *display;
    g_autoptr(GtkCssProvider) cssprovider;
    GtkWidget *title_bar;
    GtkWidget *magnified_label;
    GtkWidget *main_box;

    window = GTK_WINDOW (self);

    self->keep_open = false;
    self->text = NULL;
    self->is_label_updated = FALSE;
    self->destroy_timeout_id = 0;

    gtk_window_set_resizable (window, FALSE);
    // Application name is a proper noun and thus should not be translated
    /* gobject-linter-ignore-next-line: untranslated_string */
    gtk_window_set_title (window, "Louper");

    display = gtk_widget_get_display (GTK_WIDGET (self));

    calculate_size (self, display);

    cssprovider = gtk_css_provider_new ();
    gtk_css_provider_load_from_string (cssprovider, CSS_DATA);
    gtk_style_context_add_provider_for_display (display, GTK_STYLE_PROVIDER (cssprovider),
                                                GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

    title_bar = gtk_header_bar_new ();
    gtk_header_bar_set_show_title_buttons (GTK_HEADER_BAR (title_bar), TRUE);
    // Create a dummy Gtk.Label for the blank title
    gtk_header_bar_set_title_widget (GTK_HEADER_BAR (title_bar), gtk_label_new (NULL));
    gtk_widget_add_css_class (title_bar, GRANITE_STYLE_CLASS_FLAT);
    gtk_window_set_titlebar (window, title_bar);

    magnified_label = gtk_label_new (NULL);
    gtk_widget_set_margin_top (magnified_label, 24);
    gtk_widget_set_margin_bottom (magnified_label, 24);
    gtk_widget_set_margin_start (magnified_label, 12);
    gtk_widget_set_margin_end (magnified_label, 12);
    gtk_widget_add_css_class (magnified_label, "magnified-text");
    gtk_label_set_selectable (GTK_LABEL (magnified_label), TRUE);
    gtk_label_set_wrap (GTK_LABEL (magnified_label), TRUE);
    gtk_label_set_wrap_mode (GTK_LABEL (magnified_label), PANGO_WRAP_WORD_CHAR);

    main_box = gtk_box_new (GTK_ORIENTATION_VERTICAL, 0);
    gtk_box_append (GTK_BOX (main_box), magnified_label);

    gtk_window_set_child (window, main_box);

    g_signal_connect (window, "notify::is-active", G_CALLBACK (notify_is_active_cb), magnified_label);
}

void
louper_main_window_set_keep_open (LouperMainWindow  *self,
                                  gboolean           keep_open)
{
    g_return_if_fail (LOUPER_IS_MAIN_WINDOW (self));

    if (self->keep_open == keep_open) {
        return;
    }

    self->keep_open = keep_open;
}

void
louper_main_window_set_text (LouperMainWindow   *self,
                             const GString      *text)
{
    g_return_if_fail (LOUPER_IS_MAIN_WINDOW (self));

    if (self->text == text) {
        return;
    }

    self->text = text;
}

LouperMainWindow *
louper_main_window_new (void)
{
    return g_object_new (LOUPER_TYPE_MAIN_WINDOW,
                         NULL);
}
