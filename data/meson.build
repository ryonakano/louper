icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
  install_data(
    'icons' / i / meson.project_name() + '.png',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
  )
endforeach

i18n.merge_file(
  input: 'louper.desktop.in',
  output: meson.project_name() + '.desktop',
  po_dir: meson.project_source_root() / 'po',
  type: 'desktop',
  install: true,
  install_dir: get_option('datadir') / 'applications',
)

appstream_conf = configuration_data()
appstream_conf.set('VERSION', meson.project_version())
appstream_file_in = configure_file(
  input: 'louper.metainfo.xml.in.in',
  output: meson.project_name() + '.metainfo.xml.in',
  configuration: appstream_conf,
)

i18n.merge_file(
  input: appstream_file_in,
  output: '@BASENAME@.metainfo.xml',
  po_dir: meson.project_source_root() / 'po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo',
)
