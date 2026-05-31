project(
  'com.github.ryonakano.louper',
  'c',
  version: '2.0.6',
  meson_version: '>= 0.57.0',
  default_options: [
    'warning_level=2',
  ],
)

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  language: 'c',
)

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
  gtk_update_icon_cache: true,
)
