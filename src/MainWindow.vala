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

public class MainWindow : Hdy.ApplicationWindow {
    private const string CSS_DATA = """
    .result-text {
        font-size: 128px;
        font-weight: bold;
    }
    """;

    private Gtk.Label result_label;

    public MainWindow () {
        Object (
            resizable: false
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_data (CSS_DATA, -1);
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        result_label = new Gtk.Label (null) {
            selectable = true
        };
        result_label.get_style_context ().add_class ("result-text");

        Application.clibboard.request_text ((clipboard, text) => {
            result_label.label = text;
        });

        var grid = new Gtk.Grid () {
            margin = 24,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        grid.attach (result_label, 0, 0);

        add (grid);
        set_position (Gtk.WindowPosition.CENTER_ALWAYS);

        add_events (Gdk.EventMask.FOCUS_CHANGE_MASK);
        focus_out_event.connect ((event) => {
            /* Hide first and then destroy
             * because just destroying sometimes seems to cause the wm crashes
             */
            hide ();
            Timeout.add (500, () => {
                destroy ();
                return Gdk.EVENT_PROPAGATE;
            });
        });
    }

    protected override bool key_press_event (Gdk.EventKey key) {
        if (Gdk.ModifierType.CONTROL_MASK in key.state) {
            switch (key.keyval) {
                case Gdk.Key.c:
                    Application.clibboard.set_text (result_label.label, -1);
                    break;
            }

            return Gdk.EVENT_PROPAGATE;
        }

        switch (key.keyval) {
            case Gdk.Key.Escape:
                destroy ();
                break;
        }

        return Gdk.EVENT_PROPAGATE;
    }
}
