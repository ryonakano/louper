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
    /*
     * Get the area that we can draw windows.
     * display width * (display height - height of wingpanel, 30px)
     * e.g. If you're using 1920 * 1080 display, we can get 1920 * 1050
     */
    public static Gdk.Rectangle? primary_monitor_workarea {
        get {
            Gdk.Monitor? monitor = Application.display.get_primary_monitor ();
            return monitor.workarea;
        }
    }
    private const string CSS_DATA = """
    .result-text {
        font-size: 128px;
        font-weight: bold;
    }
    """;

    private Gtk.Label result_label;

    public MainWindow () {
        Object (
            resizable: false,
            default_width: primary_monitor_workarea.width / 2,
            default_height: primary_monitor_workarea.height / 4
        );
    }

    construct {
        var no_content_view = new Granite.Widgets.AlertView (
            _("No Text in the Clipboard"),
            _("Open the app after copying some text."),
            ""
        );

        result_label = new Gtk.Label (null) {
            selectable = true,
            wrap = true
        };
        result_label.get_style_context ().add_class ("result-text");

        var main_view = new Gtk.Grid () {
            margin = 24,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        main_view.attach (result_label, 0, 0);

        var stack = new Gtk.Stack ();
        stack.add (no_content_view);
        stack.add (main_view);

        add (stack);

        set_position (Gtk.WindowPosition.CENTER_ALWAYS);
        add_events (Gdk.EventMask.FOCUS_CHANGE_MASK);

        var cssprovider = new Gtk.CssProvider ();
        try {
            cssprovider.load_from_data (CSS_DATA, -1);
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                        cssprovider,
                                                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (GLib.Error e) {
            warning (e.message);
        }

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        Application.clibboard.request_text ((clipboard, text) => {
            if (text == null || text == "") {
                stack.visible_child = no_content_view;
            } else {
                stack.visible_child = main_view;
                result_label.label = text;
            }
        });

        focus_out_event.connect ((event) => {
            /*
             * Hide first and then destroy
             * because just destroying sometimes seems to cause the wm crashes.
             * Borrowed from https://github.com/elementary/shortcut-overlay/blob/master/src/Application.vala
             */
            hide ();
            Timeout.add (500, () => {
                destroy ();
                return Gdk.EVENT_PROPAGATE;
            });
        });
    }

    protected override bool key_press_event (Gdk.EventKey key) {
        switch (key.keyval) {
            case Gdk.Key.c:
                if (Gdk.ModifierType.CONTROL_MASK in key.state) {
                    Application.clibboard.set_text (result_label.label, -1);
                }

                break;
            case Gdk.Key.Escape:
                destroy ();
                break;
        }

        return Gdk.EVENT_PROPAGATE;
    }
}
