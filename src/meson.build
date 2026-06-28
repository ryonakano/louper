config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
  output: 'config.h',
  configuration: config_data,
)

sources = files(
  'main.c',
  'louper-application.c',
  'louper-main-window.c',
)

blueprints = custom_target('blueprints',
  input: files(
    'louper-main-window.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

asresources = gnome.compile_resources(
  'as-resources',
  'louper.gresource.xml',
  dependencies: [
    blueprints,
  ],
  source_dir: 'data',
  c_name: 'as',
)

dependencies = [
  dependency('glib-2.0', version: '>= 2.74'),
  dependency('granite-7'),
  dependency('gtk4', version: '>= 4.12'),
]

executable(
  meson.project_name(),
  asresources,
  config_file,
  sources,
  dependencies: dependencies,
  install: true,
)
