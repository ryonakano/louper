icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
  install_data(
    'icons' / i / app_id + '.png',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
  )
endforeach

i18n.merge_file(
  input: app_id + '.desktop.in',
  output: '@BASENAME@.desktop',
  po_dir: meson.project_source_root() / 'po',
  type: 'desktop',
  install: true,
  install_dir: get_option('datadir') / 'applications',
)

i18n.merge_file(
  input: app_id + '.metainfo.xml.in',
  output: '@BASENAME@.metainfo.xml',
  po_dir: meson.project_source_root() / 'po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo',
)
