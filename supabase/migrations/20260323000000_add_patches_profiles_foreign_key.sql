alter table patches
  add constraint patches_user_id_profiles_fkey
  foreign key (user_id) references profiles(id);
