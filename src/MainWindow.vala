/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Gtk.ApplicationWindow {
    private const string CSS_DATA = """
    .result-text {
        font-size: 128px;
        font-weight: bold;
    }
    """;

    /*
     * As a member variable to avoid the following warning is shown:
     *
     * (com.github.ryonakano.louper:2): Gdk-WARNING **: 12:28:19.667: losing last reference to undestroyed surface
     */
    private Gdk.Surface surface;

    construct {
        // Get the area where we can draw the app window
        surface = new Gdk.Surface.toplevel (display);
        unowned Gdk.Monitor primary_monitor = display.get_monitor_at_surface (surface);
        unowned Gdk.Rectangle primary_monitor_rectangle = primary_monitor.get_geometry ();
        default_width = primary_monitor_rectangle.width / 2;
        default_height = primary_monitor_rectangle.height / 4;
        resizable = false;
        title = "Louper";

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_data (CSS_DATA.data);
        Gtk.StyleContext.add_provider_for_display (display, cssprovider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var title_bar = new Gtk.HeaderBar () {
            show_title_buttons = true,
            // Create a dummy Gtk.Label for the blank title
            title_widget = new Gtk.Label (null)
        };
        title_bar.add_css_class (Granite.STYLE_CLASS_FLAT);
        // The 'titlebar' property requires gtk4 >= 4.6, so use the setter function instead
        set_titlebar (title_bar);

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
        main_box.append (result_label);

        child = main_box;

        unowned Gdk.Clipboard clipboard = get_primary_clipboard ();
        clipboard.read_text_async.begin (null, (obj, res) => {
            // Use the target text passed by the cmd option if specified
            if (Application.text != "") {
                result_label.label = Application.text;
                return;
            }

            try {
                result_label.label = clipboard.read_text_async.end (res);
            } catch (Error e) {
                warning (e.message);
            }
        });

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }

    protected override void state_flags_changed (Gtk.StateFlags previous_state_flags) {
        Gtk.StateFlags current_state_flags = get_state_flags ();
        if (Gtk.StateFlags.BACKDROP in current_state_flags) {
            if (Application.keep_open) {
                return;
            }

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
