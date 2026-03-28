import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_slot_write.freezed.dart';
part 'pack_slot_write.g.dart';

@freezed
abstract class PackSlotWrite with _$PackSlotWrite {
  const factory PackSlotWrite({
    required String packId,
    required int slotNumber,
    String? presetId,
    String? sampleId,
  }) = _PackSlotWrite;

  factory PackSlotWrite.fromJson(Map<String, dynamic> json) =>
      _$PackSlotWriteFromJson(json);
}
