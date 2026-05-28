-- Wavetables table
create table wavetables (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id),
  name text not null default '',
  description text not null default '',
  is_public boolean not null default false,
  file_path text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table wavetables enable row level security;

create policy "Users can read own wavetables"
  on wavetables for select using (auth.uid() = user_id);

create policy "Anyone can read public wavetables"
  on wavetables for select using (is_public = true);

create policy "Users can insert own wavetables"
  on wavetables for insert with check (auth.uid() = user_id);

create policy "Users can update own wavetables"
  on wavetables for update using (auth.uid() = user_id);

create policy "Users can delete own wavetables"
  on wavetables for delete using (auth.uid() = user_id);

-- Wavetable stars table
create table wavetable_stars (
  id uuid primary key default gen_random_uuid(),
  wavetable_id uuid not null references wavetables(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (wavetable_id, user_id)
);

alter table wavetable_stars enable row level security;

create policy "Anyone can read wavetable stars" on wavetable_stars for select using (true);
create policy "Users can insert own wavetable stars" on wavetable_stars for insert with check (auth.uid() = user_id);
create policy "Users can delete own wavetable stars" on wavetable_stars for delete using (auth.uid() = user_id);

-- Wavetables storage bucket
insert into storage.buckets (id, name, public)
  values ('wavetables', 'wavetables', false);

create policy "Users can upload own wavetables"
  on storage.objects for insert
  with check (
    bucket_id = 'wavetables'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can read own wavetable files"
  on storage.objects for select
  using (
    bucket_id = 'wavetables'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Anyone can read public wavetable files"
  on storage.objects for select
  using (
    bucket_id = 'wavetables'
    and exists (
      select 1 from wavetables
      where wavetables.file_path = name
        and wavetables.is_public = true
    )
  );

create policy "Users can delete own wavetable files"
  on storage.objects for delete
  using (
    bucket_id = 'wavetables'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Updated at trigger
create trigger set_updated_at_on_wavetables
  before update on wavetables
  for each row execute function set_updated_at();
