# Louper

![app screenshot](data/Screenshot.png)

Louper is a simple text magnification app. Originally designed for elementary OS as a prototype of the idea in https://github.com/elementary/wingpanel-indicator-a11y/issues/35

## Installation

### For Users

On elementary OS? Click the button to get Louper on AppCenter:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.louper)

Community packages maintained by volunteers are also available on some distributions:

[![Packaging status](https://repology.org/badge/vertical-allrepos/louper.svg)](https://repology.org/project/louper/versions)

### For Developers

You'll need the following dependencies to build:

* libgee-0.8-dev
* libglib2.0-dev (>= 2.42)
* libgranite-7-dev
* libgtk-4-dev
* meson (>= 0.57.0)
* valac

Run `meson setup` to configure the build environment and run `ninja` to build

```bash
meson setup builddir --prefix=/usr
ninja -C builddir
```

To install, use `ninja install`, then execute with `com.github.ryonakano.louper`

```bash
ninja install -C builddir
com.github.ryonakano.louper
```

You can also use the following command line options for debugging:

```
-k, --keep-open            Keep the app window open when unfocused
-t, --text=TEXT            The text to zoom in; the clipboard is used if none specified
```

## Usage

1. Select some text
2. Launch the app. The app shows the selected text in huge size
3. Select some part of the magnified text and press `Ctrl+C` or perform secondary click to copy it
4. Press `Esc`/`Ctrl+Q` or unfocus the window to close the app

It is recommended to assign a shortcut key to launch the app for daily use.  
Go to **System Settings→Keyboard→Shortcuts→Custom**, click the `+` button at the bottom of the right pane, and set `flatpak run com.github.ryonakano.louper` as a triggered command.

![assign shortcut](data/assign-shortcut.png)

## Contributing

Please refer to [the contribution guideline](.github/CONTRIBUTING.md) if you would like to:

- submit bug reports / feature requests
- propose coding changes
- translate the project

## Get Support

Need help in use of the app? Refer to [the discussions page](https://github.com/ryonakano/louper/discussions) to search for existing discussions or [start a new discussion](https://github.com/ryonakano/louper/discussions/new/choose) if none is relevant.
