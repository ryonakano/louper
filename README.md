# Louper

![](data/Screenshot.png)

Louper is a text magnification app designed for elementary OS. Prototype for https://github.com/elementary/wingpanel-indicator-a11y/issues/35

## Usage
1. Copy some text
2. Launch the app with `Super+Q` (You can change this shortcut in System Settings)
3. The app shows the copied text with huge size
4. Press `Ctrl+C` to copy the text showing
5. Press `Esc` or unfocus the window to close the app

## Installation

**Louper will be published to AppCenter when elementary OS 6 is out.** This is because a dependency (libhandy-1) is not available on elementary OS 5.x. For now you can test the app by building and installing from source.

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

## Contributing

There are many ways you can contribute, even if you don't know how to code.

### Reporting Bugs or Suggesting Improvements

Simply [create a new issue](https://github.com/ryonakano/louper/issues/new) describing your problem and how to reproduce or your suggestion. If you are not used to do, [this section](https://elementary.io/docs/code/reference#reporting-bugs) is for you.

### Writing Some Code

We follow [the coding style of elementary OS](https://docs.elementary.io/develop/writing-apps/code-style) and [its Human Interface Guidelines](https://docs.elementary.io/hig/). Try to respect them.

### Translating This App

I accept translations through Pull Requests. If you're not sure how to do, [the guideline I made](po/README.md) might be helpful.
