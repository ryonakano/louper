/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "louper-application.h"

#include <glib/gi18n.h>
#include <granite-7/granite-7.h>

#include "louper-main-window.h"

struct _LouperApplication {
    GtkApplication          parent_instance;

    LouperMainWindow       *window;
    GBinding               *color_scheme_binding;

    gboolean                keep_open;
    gchar                  *text;
};

G_DEFINE_FINAL_TYPE (LouperApplication, louper_application, GTK_TYPE_APPLICATION)

static const char OPT_LONG_NAME_KEEP_OPEN[] = "keep-open";
static const char OPT_LONG_NAME_TEXT[] = "text";

static const GOptionEntry app_options[] = {
    {
        .long_name          = OPT_LONG_NAME_KEEP_OPEN,
        .short_name         = 'k',
        .flags              = G_OPTION_FLAG_NONE,
        .arg                = G_OPTION_ARG_NONE,
        .arg_data           = NULL,
        .description        = N_("Keep the app window open when unfocused"),
        .arg_description    = NULL,
    },
    {
        .long_name          = OPT_LONG_NAME_TEXT,
        .short_name         = 't',
        .flags              = G_OPTION_FLAG_NONE,
        .arg                = G_OPTION_ARG_STRING,
        .arg_data           = NULL,
        .description        = N_("The text to zoom in; the clipboard is used if none specified"),
        .arg_description    = N_("TEXT"),
    },
    { NULL }
};

static void
on_quit_activate (GSimpleAction *action,
                  GVariant      *parameter,
                  gpointer       user_data)
{
    LouperApplication *self = LOUPER_APPLICATION (user_data);

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
granite_prop_to_gtk_prop (GBinding     *binding,
                          const GValue *granite_prop,
                          GValue       *gtk_prop,
                          gpointer      user_data)
{
    gint granite_prop_raw;

    granite_prop_raw = g_value_get_enum (granite_prop);
    g_value_set_boolean (gtk_prop, granite_prop_raw == GRANITE_SETTINGS_COLOR_SCHEME_DARK);

    return TRUE;
}

// Follow elementary OS-wide dark preference
static void
setup_style (LouperApplication *self)
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

    /*
     * The binding created by g_object_bind_property_full() will automatically be removed when either the source
     * or the target instances are finalized.
     * Here, however, both of the source (granite_settings) and the target (gtk_settings) instances are unowned
     * references, thus neither of them are finalized during lifetime of the Application instance.
     * So we hold a reference to the binding to remove it manually when finalizing Application.
     */
    self->color_scheme_binding = g_object_bind_property_full (granite_settings, "prefers-color-scheme",
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
    LouperApplication *self = LOUPER_APPLICATION (application);

    if (self->window) {
        gtk_window_present (GTK_WINDOW (self->window));
        return;
    }

    self->window = louper_main_window_new ();
    louper_main_window_set_keep_open (self->window, self->keep_open);
    louper_main_window_set_text (self->window, self->text);
    gtk_window_set_application (GTK_WINDOW (self->window), GTK_APPLICATION (application));
    gtk_window_present (GTK_WINDOW (self->window));
}

static gint
louper_application_handle_local_options (GApplication *application,
                                         GVariantDict *options)
{
    LouperApplication *self = LOUPER_APPLICATION (application);
    gboolean has_option;
    GVariant *value;

    has_option = g_variant_dict_contains (options, OPT_LONG_NAME_KEEP_OPEN);
    if (has_option) {
        value = g_variant_dict_lookup_value (options, OPT_LONG_NAME_KEEP_OPEN, G_VARIANT_TYPE_BOOLEAN);
        if (!value) {
            g_warning ("Failed to gtk_settings_get_default(). opt=%s", OPT_LONG_NAME_KEEP_OPEN);
            return 1;
        }

        self->keep_open = g_variant_get_boolean (value);
        g_variant_unref (value);
    }

    has_option = g_variant_dict_contains (options, OPT_LONG_NAME_TEXT);
    if (has_option) {
        value = g_variant_dict_lookup_value (options, OPT_LONG_NAME_TEXT, G_VARIANT_TYPE_STRING);
        if (!value) {
            g_warning ("Failed to g_variant_dict_lookup_value(). opt=%s", OPT_LONG_NAME_TEXT);
            return 1;
        }

        self->text = g_strdup (g_variant_get_string (value, NULL));
        g_variant_unref (value);
    }

    return -1;
}

static void
louper_application_startup (GApplication *application)
{
    LouperApplication *self = LOUPER_APPLICATION (application);

    G_APPLICATION_CLASS (louper_application_parent_class)->startup (application);

    setup_style (self);
}

static void
louper_application_dispose (GObject *object)
{
    LouperApplication *self = LOUPER_APPLICATION (object);

    g_clear_pointer (&(self->text), g_free);
    g_clear_pointer (&(self->color_scheme_binding), g_binding_unbind);

    G_OBJECT_CLASS (louper_application_parent_class)->dispose (object);
}

static void
louper_application_class_init (LouperApplicationClass *klass)
{
    GApplicationClass *application_class = G_APPLICATION_CLASS (klass);
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

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
        NULL
    };

    self->window = NULL;
    self->color_scheme_binding = NULL;
    self->keep_open = FALSE;
    self->text = NULL;

    g_application_add_main_option_entries (G_APPLICATION (self), app_options);

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
