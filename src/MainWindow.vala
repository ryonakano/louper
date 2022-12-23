/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
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
        title = "Louper";

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_data (CSS_DATA.data);
        Gtk.StyleContext.add_provider_for_display (display, cssprovider,
                                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var title_bar = new Adw.HeaderBar () {
            show_start_title_buttons = true,
            show_end_title_buttons = true,
            // Create a dummy Gtk.Label for the blank title
            title_widget = new Gtk.Label (null)
        };
        title_bar.add_css_class ("flat");

        var result_label = new Gtk.Label (null) {
            selectable = true,
            margin_top = 24,
            margin_bottom = 24,
            margin_start = 12,
            margin_end = 12,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR
        };
        result_label.add_css_class ("result-text");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (title_bar);
        main_box.append (result_label);

        content = main_box;

        unowned Gdk.Clipboard clipboard = get_primary_clipboard ();
        clipboard.read_text_async.begin (null, (obj, res) => {
            try {
                result_label.label = clipboard.read_text_async.end (res);
            } catch (Error e) {
                warning (e.message);
            }
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
        if (Application.no_close_on_unfocus) {
            /*
            * Don't close the app window automatically if the app launched
            * with the option "--no-close-on-unfocus" or its abbreviation, "-n".
            */
            return;
        }

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
