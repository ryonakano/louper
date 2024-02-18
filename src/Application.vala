/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static bool keep_open = false;
    public static string text = "";

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
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        add_main_option_entries (options);

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<Control>q", "Escape" });
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
