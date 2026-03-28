import 'package:freezed_annotation/freezed_annotation.dart';

part 'patch_write.freezed.dart';
part 'patch_write.g.dart';

@freezed
abstract class PatchWrite with _$PatchWrite {
  const factory PatchWrite({
    required String userId,
    required String name,
    required String category,
    required String patchData,
    @Default('') String description,
    @Default(false) bool isPublic,
    String? sampleId,
  }) = _PatchWrite;

  factory PatchWrite.fromJson(Map<String, dynamic> json) =>
      _$PatchWriteFromJson(json);
}
