alter table profiles
  add constraint username_not_reserved
  check (lower(username) not in (
    'editor',
    'presets',
    'packs',
    'samples',
    'wavetables',
    'patterns',
    'profile',
    'about'
  ));
