/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static Gtk.Clipboard clipboard;

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
    }

    static construct {
        // We want the content of the selection when the app launches so initializing here
        clipboard = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
    }

    protected override void activate () {
        if (window != null) {
            return;
        }

        window = new MainWindow ();
        window.set_application (this);
        window.show_all ();
    }

    public static int main (string[] args) {
        // We need to explicity init Gdk because we're initializing it in the static constructor.
        Gdk.init (ref args);
        Hdy.init ();
        return new Application ().run ();
    }
}
