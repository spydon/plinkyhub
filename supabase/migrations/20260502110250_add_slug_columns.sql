-- Introduce a per-user `slug` column on every item type so users can have
-- multiple items with the same display name. Detail-page URLs use `slug`
-- (which stays unique per user), while `name` is free to duplicate.
--
-- Slug strategy:
--   * Lowercase the name, replace anything that isn't [a-z0-9] with '-',
--     trim leading/trailing '-'. Empty results fall back to 'untitled'.
--   * On collision within the same user, append '-2', '-3', ...
--   * A BEFORE INSERT trigger fills slug when the client sends NULL/empty.
--   * Updating `name` does NOT regenerate `slug`, so existing URLs keep
--     working when an item is renamed.

-- ---------- 1. Add nullable slug column to all five item tables ----------

ALTER TABLE presets    ADD COLUMN slug text;
ALTER TABLE samples    ADD COLUMN slug text;
ALTER TABLE packs      ADD COLUMN slug text;
ALTER TABLE wavetables ADD COLUMN slug text;
ALTER TABLE patterns   ADD COLUMN slug text;

-- ---------- 2. Slug helpers ----------

-- Lowercases, replaces non-alphanumeric runs with '-', trims dashes.
CREATE OR REPLACE FUNCTION slugify(input_text text) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
  SELECT COALESCE(
    NULLIF(
      regexp_replace(
        regexp_replace(lower(input_text), '[^a-z0-9]+', '-', 'g'),
        '^-+|-+$', '', 'g'
      ),
      ''
    ),
    'untitled'
  );
$$;

-- Returns a slug unique within (table_name, user_id), trying base_slug,
-- base_slug-2, base_slug-3, ... until it lands on one that isn't taken.
CREATE OR REPLACE FUNCTION generate_unique_slug(
  table_name text,
  p_user_id uuid,
  base_name text,
  exclude_id uuid DEFAULT NULL
) RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  base_slug      text := slugify(base_name);
  candidate_slug text := base_slug;
  counter        integer := 1;
  conflict_count integer;
BEGIN
  LOOP
    EXECUTE format(
      'SELECT count(*) FROM %I WHERE user_id = $1 AND slug = $2 AND ($3::uuid IS NULL OR id <> $3)',
      table_name
    )
    INTO conflict_count
    USING p_user_id, candidate_slug, exclude_id;

    EXIT WHEN conflict_count = 0;

    counter := counter + 1;
    candidate_slug := base_slug || '-' || counter;
  END LOOP;

  RETURN candidate_slug;
END;
$$;

-- ---------- 3. Backfill slugs for existing rows ----------

-- We can't use generate_unique_slug() in a single UPDATE because each row
-- needs to consider rows already updated in this same statement. Loop in
-- creation order so the earliest item keeps the bare slug.
DO $$
DECLARE
  table_name text;
  row record;
  new_slug text;
BEGIN
  FOREACH table_name IN ARRAY ARRAY['presets', 'samples', 'packs', 'wavetables', 'patterns'] LOOP
    FOR row IN
      EXECUTE format(
        'SELECT id, user_id, name FROM %I WHERE slug IS NULL ORDER BY created_at ASC, id ASC',
        table_name
      )
    LOOP
      new_slug := generate_unique_slug(table_name, row.user_id, row.name);
      EXECUTE format('UPDATE %I SET slug = $1 WHERE id = $2', table_name)
        USING new_slug, row.id;
    END LOOP;
  END LOOP;
END $$;

-- ---------- 4. Lock down the column and swap unique constraints ----------

ALTER TABLE presets    ALTER COLUMN slug SET NOT NULL;
ALTER TABLE samples    ALTER COLUMN slug SET NOT NULL;
ALTER TABLE packs      ALTER COLUMN slug SET NOT NULL;
ALTER TABLE wavetables ALTER COLUMN slug SET NOT NULL;
ALTER TABLE patterns   ALTER COLUMN slug SET NOT NULL;

ALTER TABLE presets    DROP CONSTRAINT presets_user_id_name_unique;
ALTER TABLE samples    DROP CONSTRAINT samples_user_id_name_unique;
ALTER TABLE packs      DROP CONSTRAINT packs_user_id_name_unique;
ALTER TABLE wavetables DROP CONSTRAINT wavetables_user_id_name_unique;
ALTER TABLE patterns   DROP CONSTRAINT patterns_user_id_name_unique;

ALTER TABLE presets
  ADD CONSTRAINT presets_user_id_slug_unique UNIQUE (user_id, slug);
ALTER TABLE samples
  ADD CONSTRAINT samples_user_id_slug_unique UNIQUE (user_id, slug);
ALTER TABLE packs
  ADD CONSTRAINT packs_user_id_slug_unique UNIQUE (user_id, slug);
ALTER TABLE wavetables
  ADD CONSTRAINT wavetables_user_id_slug_unique UNIQUE (user_id, slug);
ALTER TABLE patterns
  ADD CONSTRAINT patterns_user_id_slug_unique UNIQUE (user_id, slug);

-- ---------- 5. BEFORE INSERT trigger to auto-generate slug ----------

CREATE OR REPLACE FUNCTION set_slug_before_insert() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.slug IS NULL OR NEW.slug = '' THEN
    NEW.slug := generate_unique_slug(TG_TABLE_NAME, NEW.user_id, NEW.name);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER presets_set_slug    BEFORE INSERT ON presets    FOR EACH ROW EXECUTE FUNCTION set_slug_before_insert();
CREATE TRIGGER samples_set_slug    BEFORE INSERT ON samples    FOR EACH ROW EXECUTE FUNCTION set_slug_before_insert();
CREATE TRIGGER packs_set_slug      BEFORE INSERT ON packs      FOR EACH ROW EXECUTE FUNCTION set_slug_before_insert();
CREATE TRIGGER wavetables_set_slug BEFORE INSERT ON wavetables FOR EACH ROW EXECUTE FUNCTION set_slug_before_insert();
CREATE TRIGGER patterns_set_slug   BEFORE INSERT ON patterns   FOR EACH ROW EXECUTE FUNCTION set_slug_before_insert();
