/*
* Copyright 2021 Ryo Nakano
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class Application : Gtk.Application {
    public static Gtk.Clipboard clibboard;

    private const string APP_ID = "com.github.ryonakano.louper";

    private MainWindow window;

    public Application () {
        Object (
            application_id: APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        // We want the content of the selection when the app launches so initializing here
        clibboard = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
    }

    protected override void activate () {
        if (window != null) {
            return;
        }

        window = new MainWindow ();
        window.set_application (this);
        window.show_all ();

        /*
         * Make it possible to launch the app with shortcut Super+Q.
         * Borrowed from https://github.com/cassidyjames/ideogram/blob/main/src/Application.vala
         */
        CustomShortcutSettings.init ();
        bool has_shortcut = false;
        foreach (var shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
            if (shortcut.command == APP_ID) {
                has_shortcut = true;
                return;
            }
        }

        if (!has_shortcut) {
            var shortcut = CustomShortcutSettings.create_shortcut ();
            if (shortcut != null) {
                CustomShortcutSettings.edit_shortcut (shortcut, "<Super>q");
                CustomShortcutSettings.edit_command (shortcut, APP_ID);
            }
        }
    }

    public static int main (string[] args) {
        // We need to explicity init Gdk because we're initializing it in the static constructor.
        Gdk.init (ref args);
        Hdy.init ();
        return new Application ().run ();
    }
}
