import 'package:freezed_annotation/freezed_annotation.dart';

part 'pattern_data.freezed.dart';
part 'pattern_data.g.dart';

@freezed
abstract class PatternData with _$PatternData {
  const factory PatternData({
    @Default(1) int version,
    @Default(16) int stepCount,
    @Default(0) int scaleIndex,
    @Default([]) List<List<int>> grid,
  }) = _PatternData;

  factory PatternData.fromJson(Map<String, dynamic> json) =>
      _$PatternDataFromJson(json);
}
