// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class SavedFirmware {
  SavedFirmware(this.row);

  final PostgrestPartialRow<FirmwaresRow> row;

  late final String id = row.read(Firmwares.id);

  String get userId => row.read(Firmwares.userId);

  late final String name = row.read(Firmwares.name);

  String get version => row.read(Firmwares.version);

  String get filePath => row.read(Firmwares.filePath);

  DateTime get createdAt => row.read(Firmwares.createdAt);

  late final DateTime updatedAt = row.read(Firmwares.updatedAt);

  String get description => row.read(Firmwares.description);

  bool get isBeta => row.read(Firmwares.isBeta);

  bool get isPinned => row.read(Firmwares.isPinned);

  String get username =>
      row.read(Firmwares.profiles)?.read(Profiles.username) ?? '';

  @override
  bool operator ==(Object other) =>
      other is SavedFirmware && other.id == id && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);

  /// The columns and relations the getters read.
  static final selection = <PostgrestSelectable<FirmwaresRow>>[
    Firmwares.table.allColumns,
    Firmwares.profiles(Profiles.username),
  ];
}
