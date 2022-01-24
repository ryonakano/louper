/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
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
        Gdk.Monitor primary_monitor = display.get_monitor_at_surface (new Gdk.Surface.toplevel (display));
        Gdk.Rectangle primary_monitor_rectangle = primary_monitor.get_geometry ();
        default_width = primary_monitor_rectangle.width / 2;
        default_height = primary_monitor_rectangle.height / 4;
        resizable = false;

        unowned var clipboard = get_primary_clipboard ();
        clipboard.read_text_async.begin (null, (obj, res) => {
            string? text;
            try {
                text = clipboard.read_text_async.end (res);
            } catch (Error e) {
                warning (e.message);
            }

            if (text == null || text == "") {
                var no_content_view = new Granite.Placeholder (_("No Text is Selected")) {
                    description = _("Open the app after selecting some text.")
                };
                child = no_content_view;
            } else {
                var result_label = new Gtk.Label (text) {
                    selectable = true,
                    halign = Gtk.Align.CENTER,
                    valign = Gtk.Align.CENTER,
                    wrap = true,
                    wrap_mode = Pango.WrapMode.WORD_CHAR
                };
                result_label.get_style_context ().add_class ("result-text");
                child = result_label;
            }
        });

        //  set_position (Gtk.WindowPosition.CENTER_ALWAYS);
        //  add_events (Gdk.EventMask.FOCUS_CHANGE_MASK);

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_data (CSS_DATA.data);
        Gtk.StyleContext.add_provider_for_display (display, cssprovider,
                                                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        //  focus_out_event.connect ((event) => {
        //      /*
        //       * Hide first and then destroy
        //       * because just destroying sometimes seems to cause the wm crashes.
        //       * Borrowed from elementary/shortcut-overlay, src/Application.vala
        //       */
        //      hide ();
        //      Timeout.add (500, () => {
        //          destroy ();
        //          return Gdk.EVENT_PROPAGATE;
        //      });
        //  });

        //  key_press_event.connect ((key) => {
        //      switch (key.keyval) {
        //          case Gdk.Key.c:
        //              if (Gdk.ModifierType.CONTROL_MASK in key.state) {
        //                  Application.clipboard.set_text (result_label.label, -1);
        //              }

        //              break;
        //          case Gdk.Key.q:
        //              if (Gdk.ModifierType.CONTROL_MASK in key.state) {
        //                  destroy ();
        //              }

        //              break;
        //          case Gdk.Key.Escape:
        //              destroy ();
        //              break;
        //      }

        //      return Gdk.EVENT_PROPAGATE;
        //  });
    }
}
