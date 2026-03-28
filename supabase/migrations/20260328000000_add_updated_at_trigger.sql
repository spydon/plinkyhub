CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_on_packs
  BEFORE UPDATE ON packs
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_on_patches
  BEFORE UPDATE ON patches
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_updated_at_on_samples
  BEFORE UPDATE ON samples
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
