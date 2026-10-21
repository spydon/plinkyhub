-- The set_slug_before_insert trigger fills an empty slug, so default it to
-- the empty string to let clients insert rows without sending one.
ALTER TABLE presets    ALTER COLUMN slug SET DEFAULT '';
ALTER TABLE samples    ALTER COLUMN slug SET DEFAULT '';
ALTER TABLE packs      ALTER COLUMN slug SET DEFAULT '';
ALTER TABLE wavetables ALTER COLUMN slug SET DEFAULT '';
ALTER TABLE patterns   ALTER COLUMN slug SET DEFAULT '';
