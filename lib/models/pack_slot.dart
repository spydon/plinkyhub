// ignore_for_file: experimental_member_use

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'pack_slot.freezed.dart';

@freezed
abstract class PackSlot with _$PackSlot {
  const factory PackSlot({
    required String id,
    required String packId,
    required int slotNumber,
    String? presetId,
    String? sampleId,
    String? patternId,
  }) = _PackSlot;

  /// Reads a slot embedded with every column, `pack_slots(*)`.
  factory PackSlot.fromRow(PostgrestPartialRow<PackSlotsRow> row) => PackSlot(
    id: row.read(PackSlots.id),
    packId: row.read(PackSlots.packId),
    slotNumber: row.read(PackSlots.slotNumber),
    presetId: row.read(PackSlots.presetId),
    sampleId: row.read(PackSlots.sampleId),
    patternId: row.read(PackSlots.patternId),
  );
}
