import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_write.freezed.dart';
part 'pack_write.g.dart';

@Freezed(fromJson: false, toJson: true)
abstract class PackWrite with _$PackWrite {
  const factory PackWrite({
    required String userId,
    required String name,
    @Default('') String description,
    @Default(false) bool isPublic,
    String? wavetableId,
    @Default('') String youtubeUrl,
    String? contentHash,
  }) = _PackWrite;
}
