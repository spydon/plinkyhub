// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, Uint8List>> fetchPresetData(
  SupabaseClient supabase,
  Set<String> presetIds,
) async {
  if (presetIds.isEmpty) {
    return {};
  }
  final rows = await supabase
      .table(Presets.table)
      .selectOnly([Presets.id, Presets.presetData])
      .where(Presets.id.inFilter(presetIds.toList()));
  return {
    for (final row in rows)
      row.read(Presets.id): Uint8List.fromList(
        base64Decode(row.read(Presets.presetData)),
      ),
  };
}

Future<Map<String, PostgrestPartialRow<SamplesRow>>> fetchSampleMetadata(
  SupabaseClient supabase,
  Set<String> sampleIds,
) async {
  if (sampleIds.isEmpty) {
    return {};
  }
  final rows = await supabase
      .table(Samples.table)
      .selectOnly([
        Samples.id,
        Samples.pcmFilePath,
        Samples.slicePoints,
        Samples.sliceNotes,
        Samples.pitched,
        Samples.loopMode,
      ])
      .where(Samples.id.inFilter(sampleIds.toList()));
  return {for (final row in rows) row.read(Samples.id): row};
}

Future<String> fetchWavetableFilePath(
  SupabaseClient supabase,
  String id,
) async {
  final row = await supabase
      .table(Wavetables.table)
      .selectOnly([Wavetables.filePath])
      .where(Wavetables.id.eq(id))
      .single();
  return row.read(Wavetables.filePath);
}

Future<String> fetchPatternFilePath(SupabaseClient supabase, String id) async {
  final row = await supabase
      .table(Patterns.table)
      .selectOnly([Patterns.filePath])
      .where(Patterns.id.eq(id))
      .single();
  return row.read(Patterns.filePath);
}
