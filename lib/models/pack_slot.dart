import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_slot.freezed.dart';
part 'pack_slot.g.dart';

@freezed
abstract class PackSlot with _$PackSlot {
  const factory PackSlot({
    required String id,
    @JsonKey(name: 'pack_id') required String packId,
    @JsonKey(name: 'slot_number') required int slotNumber,
    @JsonKey(name: 'patch_id') String? patchId,
    @JsonKey(name: 'sample_id') String? sampleId,
  }) = _PackSlot;

  factory PackSlot.fromJson(Map<String, dynamic> json) =>
      _$PackSlotFromJson(json);
}
