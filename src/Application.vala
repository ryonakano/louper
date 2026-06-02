/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    private static bool keep_open = false;
    private static string? text = null;

    private OptionEntry[] options = {
        {
            "keep-open", 'k', OptionFlags.NONE, OptionArg.NONE, &keep_open,
            N_("Keep the app window open when unfocused"), null
        },
        {
            "text", 't', OptionFlags.NONE, OptionArg.STRING, &text,
            N_("The text to zoom in; the clipboard is used if none specified"), N_("TEXT")
        },
        { null } // This is a null-terminated list
    };
    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
    };
    private MainWindow window;
    private Binding color_scheme_binding;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.louper",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    ~Application () {
        color_scheme_binding.unbind ();
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        add_main_option_entries (options);

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<Control>q", "Escape" });
    }

    private static bool granite_prop_to_gtk_prop (Binding binding, Value granite_prop, ref Value gtk_prop) {
        gtk_prop.set_boolean ((Granite.Settings.ColorScheme) granite_prop == Granite.Settings.ColorScheme.DARK);
        return true;
    }

    /**
     * Follow elementary OS-wide dark preference
     */
    private void setup_style () {
        unowned var granite_settings = Granite.Settings.get_default ();
        unowned var gtk_settings = Gtk.Settings.get_default ();

        /*
         * The binding created by bind_property() will automatically be removed when either the source
         * or the target instances are finalized.
         * Here, however, both of the source (granite_settings) and the target (gtk_settings) instances are unowned
         * references, thus neither of them are finalized during lifetime of the Application instance.
         * So we hold a reference to the binding to remove it manually when finalizing Application.
         */
        color_scheme_binding = granite_settings.bind_property ("prefers-color-scheme",
            gtk_settings, "gtk-application-prefer-dark-theme",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (BindingTransformFunc) granite_prop_to_gtk_prop
        );
    }

    protected override void startup () {
        base.startup ();

        setup_style ();
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new MainWindow () {
            keep_open = keep_open,
            text = text
        };
        window.set_application (this);
        window.present ();
    }

    private void on_quit_activate () {
        if (window != null) {
            window.destroy ();
        }
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
