/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Gtk.ApplicationWindow {
    private const string CSS_DATA = """
    .result-text {
        font-size: 128px;
        font-weight: bold;
    }
    """;

    construct {
        // Get the area where we can draw the app window
        unowned Gdk.Monitor primary_monitor = display.get_monitor_at_surface (new Gdk.Surface.toplevel (display));
        unowned Gdk.Rectangle primary_monitor_rectangle = primary_monitor.get_geometry ();
        default_width = primary_monitor_rectangle.width / 2;
        default_height = primary_monitor_rectangle.height / 4;
        resizable = false;
        decorated = false;
        title = "Louper";

        unowned Gdk.Clipboard clipboard = get_primary_clipboard ();
        clipboard.read_text_async.begin (null, (obj, res) => {
            string? text;
            try {
                text = clipboard.read_text_async.end (res);
            } catch (Error e) {
                warning (e.message);
            }

            var result_label = new Gtk.Label (text) {
                selectable = true,
                margin_top = 24,
                margin_bottom = 24,
                margin_start = 12,
                margin_end = 12,
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD_CHAR
            };
            result_label.get_style_context ().add_class ("result-text");
            child = result_label;
        });

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_data (CSS_DATA.data);
        Gtk.StyleContext.add_provider_for_display (display, cssprovider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_pressed.connect ((keyval, keycode, state) => {
            switch (keyval) {
                case Gdk.Key.q:
                    if (Gdk.ModifierType.CONTROL_MASK in state) {
                        destroy ();
                        return true;
                    }

                    break;
                case Gdk.Key.Escape:
                    destroy ();
                    return true;
            }

            return false;
        });
        /*
         * Gtk.Window inherits Gtk.Widget and Gtk.ShortcutManager
         * and both of them overloads add_controller methods.
         * So we need explicitly call the one in Gtk.Widget by casting
         */
        ((Gtk.Widget) this).add_controller (event_controller);
    }

    protected override void state_flags_changed (Gtk.StateFlags previous_state_flags) {
        Gtk.StateFlags current_state_flags = get_state_flags ();
        if (Gtk.StateFlags.BACKDROP in current_state_flags) {
            /*
            * Hide first and then destroy the app window when unfocused
            * because just destroying sometimes seems to cause the wm crashing.
            * Borrowed from elementary/shortcut-overlay, src/Application.vala
            */
            hide ();
            Timeout.add (250, () => {
                destroy ();
                return false;
            });
        }
    }
}
