/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include <glib/gi18n.h>
#include <gtk/gtk.h>
#include <granite-7/granite-7.h>
#include "main-window.h"
#include "application.h"

struct _LouperApplication {
    GtkApplication           parent_instance;

    LouperMainWindow        *window;

    // TODO: Backport to the current Vala code
    gboolean                 keep_open;
    GString                 *text;
};

G_DEFINE_FINAL_TYPE (LouperApplication, louper_application, GTK_TYPE_APPLICATION);

#define OPT_LONG_NAME_KEEP_OPEN         "keep-open"
#define OPT_LONG_NAME_TEXT              "text"

static const GOptionEntry options[] = {
    {
        OPT_LONG_NAME_KEEP_OPEN, 'k', G_OPTION_FLAG_NONE, G_OPTION_ARG_NONE, NULL,
        N_("Keep the app window open when unfocused"), NULL
    },
    {
        OPT_LONG_NAME_TEXT, 't', G_OPTION_FLAG_NONE, G_OPTION_ARG_STRING, NULL,
        N_("The text to zoom in; the clipboard is used if none specified"), "TEXT"
    },
    { NULL } // terminate
};

static void
on_quit_activate (GSimpleAction     *action,
                  GVariant          *parameter,
                  gpointer           user_data)
{
    LouperApplication *self;

    (void) action;
    (void) parameter;

    self = LOUPER_APPLICATION (user_data);

    if (self->window) {
        gtk_window_destroy (GTK_WINDOW (self->window));
    }
}

static const GActionEntry action_entries[] = {
    {
        .name       = "quit",
        .activate   = on_quit_activate,
    },
};

static gboolean
granite_prop_to_gtk_prop (GBinding      *binding,
                          const GValue  *from_value,
                          GValue        *to_value,
                          gpointer       user_data)
{
    gint granite_prop;

    (void) binding;
    (void) user_data;

    granite_prop = g_value_get_enum (from_value);
    g_value_set_boolean (to_value, (GraniteSettingsColorScheme) granite_prop == GRANITE_SETTINGS_COLOR_SCHEME_DARK);

    return TRUE;
}

/**
 * Follow elementary OS-wide dark preference
 */
static void
setup_style (void)
{
    GraniteSettings *granite_settings;
    GtkSettings *gtk_settings;

    granite_settings = granite_settings_get_default ();
    if (!granite_settings) {
        g_warning ("Failed to granite_settings_get_default()");
        return;
    }

    gtk_settings = gtk_settings_get_default ();
    if (!gtk_settings) {
        g_warning ("Failed to gtk_settings_get_default()");
        return;
    }

    g_object_bind_property_full (granite_settings, "prefers-color-scheme",
                                 gtk_settings, "gtk-application-prefer-dark-theme",
                                 G_BINDING_SYNC_CREATE,
                                 granite_prop_to_gtk_prop,
                                 NULL,
                                 NULL,
                                 NULL);
}

static void
louper_application_activate (GApplication *application)
{
    LouperApplication *self;

    self = LOUPER_APPLICATION (application);

    if (self->window) {
        // TODO: Backport to the current Vala code
        gtk_window_present (GTK_WINDOW (self->window));
        return;
    }

    self->window = louper_main_window_new ();
    louper_main_window_set_keep_open (self->window, self->keep_open);

    if (self->text) {
        louper_main_window_set_text (self->window, self->text);
    }

    gtk_window_set_application (GTK_WINDOW (self->window), GTK_APPLICATION (application));
    gtk_window_present (GTK_WINDOW (self->window));
}

static gint
louper_application_handle_local_options (GApplication   *application,
                                         GVariantDict   *options)
{
    LouperApplication *self;
    gboolean has_option;
    GVariant *value;

    self = LOUPER_APPLICATION (application);

    has_option = g_variant_dict_contains (options, OPT_LONG_NAME_KEEP_OPEN);
    if (has_option) {
        value = g_variant_dict_lookup_value (options, OPT_LONG_NAME_KEEP_OPEN, G_VARIANT_TYPE_BOOLEAN);
        if (!value) {
            g_warning ("Failed to gtk_settings_get_default(). opt=" OPT_LONG_NAME_KEEP_OPEN);
            return 1;
        }

        self->keep_open = g_variant_get_boolean (value);
        g_variant_unref (value);
    }

    has_option = g_variant_dict_contains (options, OPT_LONG_NAME_TEXT);
    if (has_option) {
        value = g_variant_dict_lookup_value (options, OPT_LONG_NAME_TEXT, G_VARIANT_TYPE_STRING);
        if (!value) {
            g_warning ("Failed to g_variant_dict_lookup_value(). opt=" OPT_LONG_NAME_TEXT);
            return 1;
        }

        self->text = g_string_new (g_variant_get_string (value, NULL));
        g_variant_unref (value);
    }

    return -1;
}

static void
louper_application_startup (GApplication *application)
{
    GApplicationClass *application_class;

    application_class = G_APPLICATION_CLASS (louper_application_parent_class);
    application_class->startup (application);

    setup_style ();
}

static void
louper_application_dispose (GObject *object)
{
    LouperApplication *self;

    self = LOUPER_APPLICATION (object);

    // self->window should be already freeded by gtk_window_destroy()

    if (self->text) {
        g_string_free (self->text, TRUE);
        self->text = NULL;
    }

    G_OBJECT_CLASS (louper_application_parent_class)->dispose (object);
}

static void
louper_application_class_init (LouperApplicationClass *klass)
{
    GApplicationClass *application_class;
    GObjectClass *object_class;

    application_class = G_APPLICATION_CLASS (klass);
    object_class = G_OBJECT_CLASS (klass);

    application_class->activate = louper_application_activate;
    application_class->handle_local_options = louper_application_handle_local_options;
    application_class->startup = louper_application_startup;

    object_class->dispose = louper_application_dispose;
}

static void
louper_application_init (LouperApplication *self)
{
    const char * const app_quit_accels[] = {
        "<Control>q",
        "Escape",
        NULL // terminate
    };

    self->window = NULL;
    self->keep_open = false;
    self->text = NULL;

    g_application_add_main_option_entries (G_APPLICATION (self), options);

    g_action_map_add_action_entries (G_ACTION_MAP (self), action_entries, G_N_ELEMENTS (action_entries), self);
    gtk_application_set_accels_for_action (GTK_APPLICATION (self), "app.quit", app_quit_accels);
}

LouperApplication *
louper_application_new (void)
{
    return g_object_new (LOUPER_TYPE_APPLICATION,
                         "application-id", "com.github.ryonakano.louper",
                         "flags", G_APPLICATION_DEFAULT_FLAGS,
                         NULL);
}
