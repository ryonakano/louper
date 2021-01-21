# Louper

![](Screenshot.png)

Louper is a text magnification app designed for elementary OS. Prototype for https://github.com/elementary/wingpanel-indicator-a11y/issues/35

# Usage
1. Copy some text
2. Launch the app (TODO: with some shortcut key)
3. The app shows the copied text with huge size
4. `Ctrl+C` to copy the text showing
5. Press `Esc` or unfocus the window to close the app

Build and run with

    valac --pkg gtk+-3.0 --pkg gdk-3.0 --pkg libhandy-1 src/*
    ./Application
