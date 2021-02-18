project(
    'com.github.ryonakano.louper',
    'vala', 'c',
    version: '0.1.0'
)

i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

executable(
    meson.project_name(),
    'src/Settings/CustomShortcutSettings.vala',
    'src/Application.vala',
    'src/MainWindow.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gdk-3.0'),
        dependency('libhandy-1')
    ],
    install: true
)

subdir('data')
subdir('po')
