// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A slot entry for creating, updating or sending a pack.
typedef PackSlotEntry = ({
  int slotNumber,
  String? presetId,
  String? sampleId,
  String? patternId,
});

/// A slot of a saved pack, embedded with every column, `pack_slots(*)`.
@immutable
class PackSlot {
  const PackSlot(this.row);

  final PostgrestPartialRow<PackSlotsRow> row;

  String get id => row.read(PackSlots.id);

  String get packId => row.read(PackSlots.packId);

  int get slotNumber => row.read(PackSlots.slotNumber);

  String? get presetId => row.read(PackSlots.presetId);

  String? get sampleId => row.read(PackSlots.sampleId);

  String? get patternId => row.read(PackSlots.patternId);

  PackSlotEntry get entry => (
    slotNumber: slotNumber,
    presetId: presetId,
    sampleId: sampleId,
    patternId: patternId,
  );

  @override
  bool operator ==(Object other) =>
      other is PackSlot &&
      other.id == id &&
      other.slotNumber == slotNumber &&
      other.presetId == presetId &&
      other.sampleId == sampleId &&
      other.patternId == patternId;

  @override
  int get hashCode =>
      Object.hash(id, slotNumber, presetId, sampleId, patternId);
}
