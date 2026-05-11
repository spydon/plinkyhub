-- Update create_pack_from_plinky to store loop_mode for each sample.
CREATE OR REPLACE FUNCTION create_pack_from_plinky(
  pack_data jsonb,
  samples_data jsonb DEFAULT '[]'::jsonb,
  presets_data jsonb DEFAULT '[]'::jsonb,
  wavetable_data jsonb DEFAULT NULL,
  patterns_data jsonb DEFAULT '[]'::jsonb,
  pack_slots_data jsonb DEFAULT '[]'::jsonb
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  created_pack_id uuid;
  created_wavetable_id uuid;
  sample_row jsonb;
  preset_row jsonb;
  pattern_row jsonb;
  slot_row jsonb;
  created_id uuid;
  resolved_sample_id uuid;
  sample_id_map jsonb := '{}'::jsonb;
  preset_id_map jsonb := '{}'::jsonb;
  pattern_id_map jsonb := '{}'::jsonb;
BEGIN
  -- Insert samples and build a slot_index -> id map.
  FOR sample_row IN SELECT * FROM jsonb_array_elements(samples_data)
  LOOP
    IF sample_row->>'existing_id' IS NOT NULL THEN
      created_id := (sample_row->>'existing_id')::uuid;
    ELSE
      INSERT INTO samples (
        user_id, name, file_path, pcm_file_path, description, is_public,
        slice_points, base_note, fine_tune, pitched, slice_notes, loop_mode,
        content_hash
      ) VALUES (
        (sample_row->>'user_id')::uuid,
        sample_row->>'name',
        sample_row->>'file_path',
        sample_row->>'pcm_file_path',
        COALESCE(sample_row->>'description', ''),
        COALESCE((sample_row->>'is_public')::boolean, false),
        COALESCE(
          (SELECT array_agg(elem::double precision)
           FROM jsonb_array_elements_text(sample_row->'slice_points') AS elem),
          ARRAY[]::double precision[]
        ),
        COALESCE((sample_row->>'base_note')::integer, 60),
        COALESCE((sample_row->>'fine_tune')::integer, 0),
        COALESCE((sample_row->>'pitched')::boolean, false),
        COALESCE(
          (SELECT array_agg(elem::integer)
           FROM jsonb_array_elements_text(sample_row->'slice_notes') AS elem),
          ARRAY[]::integer[]
        ),
        COALESCE((sample_row->>'loop_mode')::smallint, 0),
        sample_row->>'content_hash'
      )
      RETURNING id INTO created_id;
    END IF;

    sample_id_map := sample_id_map || jsonb_build_object(
      sample_row->>'slot_index', created_id::text
    );
  END LOOP;

  -- Insert wavetable if provided.
  IF wavetable_data IS NOT NULL THEN
    IF wavetable_data->>'existing_id' IS NOT NULL THEN
      created_wavetable_id := (wavetable_data->>'existing_id')::uuid;
    ELSE
      INSERT INTO wavetables (user_id, name, file_path, description, is_public, content_hash)
      VALUES (
        (wavetable_data->>'user_id')::uuid,
        wavetable_data->>'name',
        wavetable_data->>'file_path',
        COALESCE(wavetable_data->>'description', ''),
        COALESCE((wavetable_data->>'is_public')::boolean, false),
        wavetable_data->>'content_hash'
      )
      RETURNING id INTO created_wavetable_id;
    END IF;
  END IF;

  -- Insert patterns and build an index -> id map.
  FOR pattern_row IN SELECT * FROM jsonb_array_elements(patterns_data)
  LOOP
    IF pattern_row->>'existing_id' IS NOT NULL THEN
      created_id := (pattern_row->>'existing_id')::uuid;
    ELSE
      INSERT INTO patterns (user_id, name, file_path, description, is_public, content_hash)
      VALUES (
        (pattern_row->>'user_id')::uuid,
        pattern_row->>'name',
        pattern_row->>'file_path',
        COALESCE(pattern_row->>'description', ''),
        COALESCE((pattern_row->>'is_public')::boolean, false),
        pattern_row->>'content_hash'
      )
      RETURNING id INTO created_id;
    END IF;

    pattern_id_map := pattern_id_map || jsonb_build_object(
      pattern_row->>'pattern_index', created_id::text
    );
  END LOOP;

  -- Insert presets and build a slot_index -> id map.
  FOR preset_row IN SELECT * FROM jsonb_array_elements(presets_data)
  LOOP
    -- Resolve the sample_id from sample_id_map if sample_slot_index is set.
    resolved_sample_id := NULL;
    IF preset_row->>'sample_slot_index' IS NOT NULL THEN
      resolved_sample_id := (sample_id_map->>(preset_row->>'sample_slot_index'))::uuid;
    END IF;

    IF preset_row->>'existing_id' IS NOT NULL THEN
      created_id := (preset_row->>'existing_id')::uuid;
      -- Update sample_id on existing preset if we resolved one.
      IF resolved_sample_id IS NOT NULL THEN
        UPDATE presets SET sample_id = resolved_sample_id WHERE id = created_id;
      END IF;
    ELSE
      INSERT INTO presets (
        user_id, name, category, preset_data, description, is_public,
        content_hash, sample_id
      ) VALUES (
        (preset_row->>'user_id')::uuid,
        preset_row->>'name',
        preset_row->>'category',
        preset_row->>'preset_data',
        COALESCE(preset_row->>'description', ''),
        COALESCE((preset_row->>'is_public')::boolean, false),
        preset_row->>'content_hash',
        resolved_sample_id
      )
      RETURNING id INTO created_id;
    END IF;

    preset_id_map := preset_id_map || jsonb_build_object(
      preset_row->>'slot_index', created_id::text
    );
  END LOOP;

  -- Insert the pack.
  INSERT INTO packs (
    user_id, name, description, is_public, wavetable_id, youtube_url,
    content_hash
  ) VALUES (
    (pack_data->>'user_id')::uuid,
    pack_data->>'name',
    COALESCE(pack_data->>'description', ''),
    COALESCE((pack_data->>'is_public')::boolean, false),
    created_wavetable_id,
    COALESCE(pack_data->>'youtube_url', ''),
    pack_data->>'content_hash'
  )
  RETURNING id INTO created_pack_id;

  -- Insert pack slots, resolving references from the id maps.
  FOR slot_row IN SELECT * FROM jsonb_array_elements(pack_slots_data)
  LOOP
    INSERT INTO pack_slots (pack_id, slot_number, preset_id, sample_id, pattern_id)
    VALUES (
      created_pack_id,
      (slot_row->>'slot_number')::integer,
      CASE WHEN slot_row->>'preset_slot_index' IS NOT NULL
        THEN (preset_id_map->>( slot_row->>'preset_slot_index'))::uuid
        ELSE NULL
      END,
      CASE WHEN slot_row->>'sample_slot_index' IS NOT NULL
        THEN (sample_id_map->>( slot_row->>'sample_slot_index'))::uuid
        ELSE NULL
      END,
      CASE WHEN slot_row->>'pattern_index' IS NOT NULL
        THEN (pattern_id_map->>( slot_row->>'pattern_index'))::uuid
        ELSE NULL
      END
    );
  END LOOP;

  RETURN jsonb_build_object('pack_id', created_pack_id);
END;
$$;
