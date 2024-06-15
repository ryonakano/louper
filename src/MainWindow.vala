/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Gtk.ApplicationWindow {
    private const string CSS_DATA = """
    .magnified-text {
        font-size: 128px;
        font-weight: bold;
    }
    """;

    // Member variable to avoid the following warning is shown:
    // Gdk-WARNING **: 12:28:19.667: losing last reference to undestroyed surface
    private Gdk.Surface surface;

    private bool is_label_updated = false;
    private Gtk.Label magnified_label;

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
        cssprovider.load_from_string (CSS_DATA);
        Gtk.StyleContext.add_provider_for_display (display, cssprovider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var title_bar = new Gtk.HeaderBar () {
            show_title_buttons = true,
            // Create a dummy Gtk.Label for the blank title
            title_widget = new Gtk.Label (null)
        };
        title_bar.add_css_class (Granite.STYLE_CLASS_FLAT);
        titlebar = title_bar;

        magnified_label = new Gtk.Label (null) {
            selectable = true,
            margin_top = 24,
            margin_bottom = 24,
            margin_start = 12,
            margin_end = 12,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR
        };
        magnified_label.add_css_class ("magnified-text");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (magnified_label);

        child = main_box;

        // Watch for focus change to update the label.
        notify["is-active"].connect (() => {
            if (!is_active) {
                // Do nothing when the window lost focus.
                // NOTE: We don't close the window here because is-active gets false also when opening the context menu.
                // We handle it in state_flags_changed instead so that users can use the context menu.
                return;
            }

            if (is_label_updated) {
                // Do nothing if the label text is already set.
                return;
            }

            is_label_updated = true;

            // When the window get focused, update the label with the specified text or clipboard content.
            // NOTE: The reason to update the label after the window get focused is that
            // getting clipboard content is not allowed until that happens on Wayland.
            // See https://gitlab.gnome.org/GNOME/gtk/-/issues/1874#note_509304
            update_magnified_label.begin ();
        });

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }

    private async void update_magnified_label () {
        if (Application.text != null) {
            // Set the text passed by the command line option if specified
            magnified_label.label = Application.text;
        } else {
            // Otherwise set the text loaded from clipboard
            magnified_label.label = yield load_clipboard ();
        }
    }

    private async string load_clipboard () {
        unowned Gdk.Clipboard clipboard = get_primary_clipboard ();

        string content = "";
        try {
            content = yield clipboard.read_text_async (null);
        } catch (Error e) {
            warning ("Failed to read text from clipboard: %s", e.message);
        }

        return content;
    }

    protected override void state_flags_changed (Gtk.StateFlags previous_state_flags) {
        Gtk.StateFlags current_state_flags = get_state_flags ();
        if (Gtk.StateFlags.BACKDROP in current_state_flags) {
            if (Application.keep_open) {
                return;
            }

            // Hide first and then destroy the app window when unfocused
            // because just destroying sometimes seems to cause the wm crashing.
            // Borrowed from shortcut-overlay by elementary.
            hide ();
            Timeout.add (250, () => {
                destroy ();
                return Source.REMOVE;
            });
        }
    }
}
