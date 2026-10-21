import 'package:freezed_annotation/freezed_annotation.dart';

part 'matched_entry.freezed.dart';

/// A row matched by content hash when comparing local items against
/// the remote catalog. Carries only the identity needed to reuse the
/// existing entry instead of uploading a duplicate.
@freezed
abstract class MatchedEntry with _$MatchedEntry {
  const factory MatchedEntry({
    required String id,
    required String name,
  }) = _MatchedEntry;
}
