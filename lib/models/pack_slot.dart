import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_slot.freezed.dart';
part 'pack_slot.g.dart';

@freezed
abstract class PackSlot with _$PackSlot {
  const factory PackSlot({
    required String id,
    required String packId,
    required int slotNumber,
    String? presetId,
    String? sampleId,
  }) = _PackSlot;

  factory PackSlot.fromJson(Map<String, dynamic> json) =>
      _$PackSlotFromJson(json);
}
