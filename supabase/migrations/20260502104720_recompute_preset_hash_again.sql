-- Recompute preset content_hash with P_SAMPLE zeroed out.
--
-- The earlier 20260403200000 migration recomputed hashes correctly, but the
-- direct preset upload path in lib/pages/presets/providers/saved_presets_notifier.dart
-- continued to use the raw computeContentHash() helper (no P_SAMPLE zeroing)
-- until 20260502, so any preset inserted between those dates ended up with a
-- hash that does not match the zeroed-P_SAMPLE hashes the device parser uses
-- when matching pack content. This caused load-from-Plinky pack creation to
-- fail with the (user_id, name) unique constraint on previously-uploaded
-- presets.
--
-- Re-applying the same recompute brings any drifted rows back into agreement
-- with the device-side hash and is a no-op for already-correct rows.

UPDATE presets
SET content_hash = encode(
  extensions.digest(
    set_byte(set_byte(decode(preset_data, 'base64'), 832, 0), 833, 0),
    'sha256'
  ),
  'hex'
)
WHERE content_hash IS NOT NULL
  AND preset_data IS NOT NULL
  AND length(decode(preset_data, 'base64')) > 833;
