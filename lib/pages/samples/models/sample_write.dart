import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/saved_sample.dart';

part 'sample_write.freezed.dart';
part 'sample_write.g.dart';

@Freezed(fromJson: false, toJson: true)
abstract class SampleWrite with _$SampleWrite {
  const factory SampleWrite({
    required String userId,
    required String name,
    required String filePath,
    required String pcmFilePath,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default(defaultSlicePoints) List<double> slicePoints,
    @Default(60) int baseNote,
    @Default(0) int fineTune,
    @Default(false) bool pitched,
    @Default(defaultSliceNotes) List<int> sliceNotes,
    @Default(0) int loopMode,
    String? contentHash,
  }) = _SampleWrite;
}
