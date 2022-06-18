project(
    'com.github.ryonakano.louper',
    'vala', 'c',
    version: '1.0.2',
    meson_version: '>=0.57.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

sources = files(
    'src' / 'Application.vala',
    'src' / 'MainWindow.vala'
)

executable(
    meson.project_name(),
    config_file,
    sources,
    dependencies: [
        dependency('gtk4'),
        dependency('granite-7')
    ],
    install: true
)

subdir('data')
subdir('po')

gnome.post_install(
    gtk_update_icon_cache: true
)
