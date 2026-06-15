
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'username', ''),
      gen_random_uuid()::text
    )
  );
  return new;
end;
$function$;

ALTER TABLE profiles DROP CONSTRAINT "username_not_reserved";

alter table profiles
  add constraint username_not_reserved
  check (lower(username) not in (
    '',
    'my-plinky',
    'editor',
    'presets',
    'packs',
    'samples',
    'wavetables',
    'patterns',
    'users',
    'profile',
    'firmware',
    'about'
  ));
