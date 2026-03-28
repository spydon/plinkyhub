-- Rename patches table to presets
ALTER TABLE patches RENAME TO presets;

-- Rename patch_data column to preset_data
ALTER TABLE presets RENAME COLUMN patch_data TO preset_data;

-- Rename patch_stars table to preset_stars
ALTER TABLE patch_stars RENAME TO preset_stars;

-- Rename patch_id column in preset_stars
ALTER TABLE preset_stars RENAME COLUMN patch_id TO preset_id;

-- Rename patch_id column in pack_slots
ALTER TABLE pack_slots RENAME COLUMN patch_id TO preset_id;

-- Rename the updated_at trigger
DROP TRIGGER IF EXISTS set_updated_at_on_patches ON presets;
CREATE TRIGGER set_updated_at_on_presets
  BEFORE UPDATE ON presets
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
