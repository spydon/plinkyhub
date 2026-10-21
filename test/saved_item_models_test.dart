// ignore_for_file: experimental_member_use, invalid_use_of_internal_member

import 'package:flutter_test/flutter_test.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/firmware/models/saved_firmware.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _createdAt = '2026-01-01T10:00:00+00:00';
const _updatedAt = '2026-01-02T10:00:00+00:00';

Map<String, dynamic> _itemColumns() => {
  'id': 'item-id',
  'user_id': 'user-id',
  'name': 'Item',
  'created_at': _createdAt,
  'updated_at': _updatedAt,
  'slug': 'item',
  'description': 'Description',
  'is_public': true,
  'profiles': {'username': 'owner'},
};

/// Builds a row of [selection] from [json], as a response to it would be read.
PostgrestPartialRow<Row> _row<Row>(
  List<PostgrestSelectable<Row>> selection,
  Map<String, dynamic> json,
) => PostgrestPartialRow.fromSelections(json, selection);

void main() {
  // Each test reads every getter of its model. A getter whose column is
  // missing from the model's selection throws a StateError here instead of
  // in the UI. Add new getters to these lists.
  test('SavedPreset getters read selected columns', () {
    final preset = SavedPreset(
      _row(SavedPreset.selection, {
        ..._itemColumns(),
        'category': 'lead',
        'preset_data': 'AAAA',
        'youtube_url': '',
        'sample_id': 'sample-id',
        'preset_stars': [
          {'count': 3},
        ],
        'samples': {
          'name': 'Kick',
          'slug': 'kick',
          'profiles': {'username': 'sampler'},
        },
      }),
    );
    final values = [
      preset.id,
      preset.userId,
      preset.name,
      preset.category,
      preset.presetData,
      preset.createdAt,
      preset.updatedAt,
      preset.slug,
      preset.description,
      preset.isPublic,
      preset.username,
      preset.youtubeUrl,
      preset.sampleId,
      preset.sampleName,
      preset.sampleSlug,
      preset.sampleUsername,
      preset.starCount,
      preset.isStarred,
    ];
    expect(values, hasLength(18));
    expect(preset.starCount, 3);
    expect(preset.username, 'owner');
    expect(preset.sampleUsername, 'sampler');
    expect(preset.updatedAt, DateTime.parse(_updatedAt));
  });

  test('SavedSample getters read selected columns', () {
    final sample = SavedSample(
      _row(SavedSample.selection, {
        ..._itemColumns(),
        'file_path': 'a.wav',
        'pcm_file_path': 'a.pcm',
        'slice_points': defaultSlicePoints,
        'base_note': 60,
        'fine_tune': 0,
        'pitched': false,
        'slice_notes': defaultSliceNotes,
        'loop_mode': 0,
        'content_hash': 'hash',
        'sample_stars': <Object>[],
      }),
    );
    final values = [
      sample.id,
      sample.userId,
      sample.name,
      sample.filePath,
      sample.pcmFilePath,
      sample.createdAt,
      sample.updatedAt,
      sample.slug,
      sample.description,
      sample.isPublic,
      sample.username,
      sample.slicePoints,
      sample.baseNote,
      sample.fineTune,
      sample.pitched,
      sample.sliceNotes,
      sample.loopMode,
      sample.contentHash,
      sample.starCount,
      sample.isStarred,
    ];
    expect(values, hasLength(20));
    expect(sample.starCount, 0);
    expect(sample.slicePoints, defaultSlicePoints);
  });

  test('SavedPattern getters read selected columns', () {
    final pattern = SavedPattern(
      _row(SavedPattern.selection, {
        ..._itemColumns(),
        'file_path': 'p.json',
        'content_hash': null,
        'pattern_stars': [
          {'count': 1},
        ],
      }),
    );
    final values = [
      pattern.id,
      pattern.userId,
      pattern.name,
      pattern.filePath,
      pattern.createdAt,
      pattern.updatedAt,
      pattern.slug,
      pattern.description,
      pattern.isPublic,
      pattern.username,
      pattern.contentHash,
      pattern.starCount,
      pattern.isStarred,
    ];
    expect(values, hasLength(13));
    expect(pattern.starCount, 1);
  });

  test('SavedWavetable getters read selected columns', () {
    final wavetable = SavedWavetable(
      _row(SavedWavetable.selection, {
        ..._itemColumns(),
        'file_path': 'w.uf2',
        'youtube_url': '',
        'content_hash': 'hash',
        'wavetable_stars': [
          {'count': 2},
        ],
      }),
    );
    final values = [
      wavetable.id,
      wavetable.userId,
      wavetable.name,
      wavetable.filePath,
      wavetable.createdAt,
      wavetable.updatedAt,
      wavetable.slug,
      wavetable.description,
      wavetable.isPublic,
      wavetable.username,
      wavetable.youtubeUrl,
      wavetable.contentHash,
      wavetable.starCount,
      wavetable.isStarred,
    ];
    expect(values, hasLength(14));
    expect(wavetable.starCount, 2);
  });

  test('SavedPack and PackSlot getters read selected columns', () {
    final pack = SavedPack(
      _row(SavedPack.selection, {
        ..._itemColumns(),
        'wavetable_id': 'wavetable-id',
        'youtube_url': '',
        'content_hash': null,
        'pack_slots': [
          {
            'id': 'slot-id',
            'pack_id': 'item-id',
            'slot_number': 3,
            'preset_id': 'preset-id',
            'sample_id': null,
            'pattern_id': null,
          },
        ],
        'pack_stars': [
          {'count': 4},
        ],
      }),
    );
    final slot = pack.slots.single;
    final values = [
      pack.id,
      pack.userId,
      pack.name,
      pack.createdAt,
      pack.updatedAt,
      pack.slug,
      pack.description,
      pack.isPublic,
      pack.username,
      pack.slots,
      pack.wavetableId,
      pack.youtubeUrl,
      pack.contentHash,
      pack.starCount,
      pack.isStarred,
      slot.id,
      slot.packId,
      slot.slotNumber,
      slot.presetId,
      slot.sampleId,
      slot.patternId,
      slot.entry,
    ];
    expect(values, hasLength(22));
    expect(pack.starCount, 4);
    expect(slot.entry.slotNumber, 3);
    expect(identical(pack.slots, pack.slots), isTrue);
  });

  test('SavedFirmware getters read selected columns', () {
    final firmware = SavedFirmware(
      _row(SavedFirmware.selection, {
        'id': 'firmware-id',
        'user_id': 'user-id',
        'name': 'Firmware',
        'version': '1.0',
        'file_path': 'f.uf2',
        'created_at': _createdAt,
        'updated_at': _updatedAt,
        'description': '',
        'is_beta': false,
        'is_pinned': true,
        'profiles': {'username': 'owner'},
      }),
    );
    final values = [
      firmware.id,
      firmware.userId,
      firmware.name,
      firmware.version,
      firmware.filePath,
      firmware.createdAt,
      firmware.updatedAt,
      firmware.description,
      firmware.isBeta,
      firmware.isPinned,
      firmware.username,
    ];
    expect(values, hasLength(11));
    expect(firmware.isPinned, isTrue);
  });

  test('equality follows id, updatedAt and the star fields', () {
    SavedPattern pattern() => SavedPattern(
      _row(SavedPattern.selection, {
        ..._itemColumns(),
        'file_path': 'p.json',
        'content_hash': null,
        'pattern_stars': <Object>[],
      }),
    );
    final first = pattern();
    final second = pattern();
    expect(first, second);
    expect(first.hashCode, second.hashCode);

    final starred = first.withStar(isStarred: true, starCount: 1);
    expect(starred, isNot(first));
    expect(starred.isStarred, isTrue);
    expect(starred.starCount, 1);
    expect(starred.row, same(first.row));
  });
}
