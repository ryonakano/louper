/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static bool no_close_on_unfocus = false;

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
                "no-close-on-unfocus", 'n', OptionFlags.NONE, OptionArg.NONE, &no_close_on_unfocus,
                _("Prevent the app window from closing automatically on unfocused"), null
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
