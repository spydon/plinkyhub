// ignore_for_file: experimental_member_use

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saved_sample.freezed.dart';

const defaultSlicePoints = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875];

/// Default slice notes: all set to 48 (C4 in Plinky's note scheme, which maps
/// to MIDI note 60).
const defaultSliceNotes = [48, 48, 48, 48, 48, 48, 48, 48];

@freezed
abstract class SavedSample with _$SavedSample implements Searchable {
  const factory SavedSample({
    required String id,
    required String userId,
    required String name,
    required String filePath,
    required String pcmFilePath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String slug,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String username,
    @Default(0) int starCount,
    @Default(false) bool isStarred,
    @Default(defaultSlicePoints) List<double> slicePoints,
    @Default(60) int baseNote,
    @Default(0) int fineTune,
    @Default(false) bool pitched,
    @Default(defaultSliceNotes) List<int> sliceNotes,
    @Default(0) int loopMode,
    String? contentHash,
  }) = _SavedSample;

  factory SavedSample.fromRow(
    PostgrestPartialRow<SamplesRow> row, {
    bool isStarred = false,
  }) => SavedSample(
    id: row.read(Samples.id),
    userId: row.read(Samples.userId),
    name: row.read(Samples.name),
    filePath: row.read(Samples.filePath),
    pcmFilePath: row.read(Samples.pcmFilePath),
    createdAt: row.read(Samples.createdAt),
    updatedAt: row.read(Samples.updatedAt),
    slug: row.read(Samples.slug),
    description: row.read(Samples.description),
    isPublic: row.read(Samples.isPublic),
    username: row.read(Samples.profiles)?.read(Profiles.username) ?? '',
    starCount: readStarCount(row, Samples.sampleStars, sampleStarsTable),
    isStarred: isStarred,
    slicePoints: row.read(Samples.slicePoints),
    baseNote: row.read(Samples.baseNote),
    fineTune: row.read(Samples.fineTune),
    pitched: row.read(Samples.pitched),
    sliceNotes: row.read(Samples.sliceNotes),
    loopMode: row.read(Samples.loopMode),
    contentHash: row.read(Samples.contentHash),
  );

  /// The columns and relations [SavedSample.fromRow] reads.
  static final selection = <PostgrestSelectable<SamplesRow>>[
    Samples.id,
    Samples.userId,
    Samples.name,
    Samples.filePath,
    Samples.pcmFilePath,
    Samples.createdAt,
    Samples.updatedAt,
    Samples.slug,
    Samples.description,
    Samples.isPublic,
    Samples.slicePoints,
    Samples.baseNote,
    Samples.fineTune,
    Samples.pitched,
    Samples.sliceNotes,
    Samples.loopMode,
    Samples.contentHash,
    Samples.profiles(Profiles.username),
    Samples.sampleStars(sampleStarsTable.count),
  ];
}
