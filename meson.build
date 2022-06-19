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

if get_option('enable_debug')
    add_project_arguments('--debug', language: 'vala')
endif

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
        dependency('gdk-3.0'),
        dependency('granite', version: '>= 5.4.0'),
        dependency('gtk+-3.0'),
        dependency('libhandy-1')
    ],
    install: true
)

subdir('data')
subdir('po')

gnome.post_install(
    gtk_update_icon_cache: true
)
