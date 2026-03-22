import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/pack_slot.dart';

part 'saved_pack.freezed.dart';
part 'saved_pack.g.dart';

@freezed
abstract class SavedPack with _$SavedPack {
  const factory SavedPack({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default('') String description,
    @Default(false) @JsonKey(name: 'is_public') bool isPublic,
    @Default([]) @JsonKey(name: 'pack_slots') List<PackSlot> slots,
  }) = _SavedPack;

  factory SavedPack.fromJson(Map<String, dynamic> json) =>
      _$SavedPackFromJson(json);
}
