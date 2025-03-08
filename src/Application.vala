/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static bool keep_open = false;
    public static string? text = null;

    private OptionEntry[] options = {
        {
            "keep-open", 'k', OptionFlags.NONE, OptionArg.NONE, &keep_open,
            _("Keep the app window open when unfocused"), null
        },
        {
            "text", 't', OptionFlags.NONE, OptionArg.STRING, &text,
            _("The text to zoom in; the clipboard is used if none specified"), "TEXT"
        },
        { null } // This is a null-terminated list
    };
    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
    };
    private MainWindow window;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.louper",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
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

    /**
     * Follow elementary OS-wide dark preference
     */
    private void setup_style () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.bind_property ("prefers-color-scheme", gtk_settings, "gtk-application-prefer-dark-theme",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            ((binding, granite_prop, ref gtk_prop) => {
                gtk_prop.set_boolean ((Granite.Settings.ColorScheme) granite_prop == Granite.Settings.ColorScheme.DARK);
                return true;
            })
        );
    }

    protected override void startup () {
        base.startup ();

        setup_style ();
    }

    protected override void activate () {
        if (window != null) {
            return;
        }

        window = new MainWindow ();
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
