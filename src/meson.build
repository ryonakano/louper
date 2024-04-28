config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

sources = files(
    'Application.vala',
    'MainWindow.vala'
)

executable(
    meson.project_name(),
    config_file,
    sources,
    dependencies: [
        dependency('glib-2.0', version: '>= 2.74'),
        dependency('granite-7'),
        dependency('gtk4')
    ],
    install: true
)
