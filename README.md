# Louper

![](data/Screenshot.png)

Louper is a text magnification app designed for elementary OS. Prototype for https://github.com/elementary/wingpanel-indicator-a11y/issues/35

## Usage
1. Copy some text
2. Launch the app (TODO: with some shortcut key)
3. The app shows the copied text with huge size
4. Press `Ctrl+C` to copy the text showing
5. Press `Esc` or unfocus the window to close the app

## Installation

### For Developers

You'll need the following dependencies to build:

* libgranite-dev (>= 5.4.0)
* libgtk-3.0-dev
* libhandy-1-dev
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.louper`

    ninja install
    com.github.ryonakano.louper
