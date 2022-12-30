/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static bool keep_open = false;
    public static string text = "";

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

        // Set application options
        OptionEntry[] options = {
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
        add_main_option_entries (options);
    }

    protected override void activate () {
        if (window != null) {
            return;
        }

        window = new MainWindow ();
        window.set_application (this);
        window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
