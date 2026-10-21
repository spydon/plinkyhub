// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const defaultSlicePoints = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875];

/// Default slice notes: all set to 48 (C4 in Plinky's note scheme, which maps
/// to MIDI note 60).
const defaultSliceNotes = [48, 48, 48, 48, 48, 48, 48, 48];

@immutable
class SavedSample with Searchable {
  SavedSample(this.row, {this.isStarred = false, int? starCount})
    : starCount =
          starCount ??
          readStarCount(row, Samples.sampleStars, sampleStarsTable);

  final PostgrestPartialRow<SamplesRow> row;

  @override
  final bool isStarred;

  @override
  final int starCount;

  @override
  late final String id = row.read(Samples.id);

  @override
  String get userId => row.read(Samples.userId);

  @override
  late final String name = row.read(Samples.name);

  String get filePath => row.read(Samples.filePath);

  String get pcmFilePath => row.read(Samples.pcmFilePath);

  DateTime get createdAt => row.read(Samples.createdAt);

  @override
  late final DateTime updatedAt = row.read(Samples.updatedAt);

  String get slug => row.read(Samples.slug);

  @override
  String get description => row.read(Samples.description);

  bool get isPublic => row.read(Samples.isPublic);

  @override
  String get username =>
      row.read(Samples.profiles)?.read(Profiles.username) ?? '';

  List<double> get slicePoints => row.read(Samples.slicePoints);

  int get baseNote => row.read(Samples.baseNote);

  int get fineTune => row.read(Samples.fineTune);

  bool get pitched => row.read(Samples.pitched);

  List<int> get sliceNotes => row.read(Samples.sliceNotes);

  int get loopMode => row.read(Samples.loopMode);

  String? get contentHash => row.read(Samples.contentHash);

  SavedSample withStar({required bool isStarred, required int starCount}) =>
      SavedSample(row, isStarred: isStarred, starCount: starCount);

  @override
  bool operator ==(Object other) =>
      other is SavedSample &&
      other.id == id &&
      other.updatedAt == updatedAt &&
      other.isStarred == isStarred &&
      other.starCount == starCount;

  @override
  int get hashCode => Object.hash(id, updatedAt, isStarred, starCount);

  /// The columns and relations the getters read.
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
