import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_write.freezed.dart';
part 'pack_write.g.dart';

@freezed
abstract class PackWrite with _$PackWrite {
  const factory PackWrite({
    required String userId,
    required String name,
    @Default('') String description,
    @Default(false) bool isPublic,
  }) = _PackWrite;

  factory PackWrite.fromJson(Map<String, dynamic> json) =>
      _$PackWriteFromJson(json);
}
