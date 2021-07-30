project(
    'com.github.ryonakano.louper',
    'vala', 'c',
    version: '0.1.1',
    meson_version: '>=0.49.0'
)

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
        dependency('gdk-3.0'),
        dependency('granite', version: '>= 5.4.0'),
        dependency('gtk+-3.0'),
        dependency('libhandy-1')
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson' / 'post_install.py')
