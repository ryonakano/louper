/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    // Store application options data
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
            OptionEntry () {
                long_name       = "keep-open",
                short_name      = 'k',
                flags           = OptionFlags.NONE,
                arg             = OptionArg.NONE,
                arg_data        = &keep_open,
                description     = _("Keep the app window open when unfocused"),
                arg_description = null,
            },

            OptionEntry () {
                long_name       = "text",
                short_name      = 't',
                flags           = OptionFlags.NONE,
                arg             = OptionArg.STRING,
                arg_data        = &text,
                description     = _("The text to zoom in; the clipboard is used if none specified"),
                arg_description = "TEXT",
            },

            // sentinel
            { null }
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
