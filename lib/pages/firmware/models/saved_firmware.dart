// ignore_for_file: experimental_member_use

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saved_firmware.freezed.dart';

@freezed
abstract class SavedFirmware with _$SavedFirmware {
  const factory SavedFirmware({
    required String id,
    required String userId,
    required String name,
    required String version,
    required String filePath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String description,
    @Default(false) bool isBeta,
    @Default(false) bool isPinned,
    @Default('') String username,
  }) = _SavedFirmware;

  factory SavedFirmware.fromRow(PostgrestPartialRow<FirmwaresRow> row) =>
      SavedFirmware(
        id: row.read(Firmwares.id),
        userId: row.read(Firmwares.userId),
        name: row.read(Firmwares.name),
        version: row.read(Firmwares.version),
        filePath: row.read(Firmwares.filePath),
        createdAt: row.read(Firmwares.createdAt),
        updatedAt: row.read(Firmwares.updatedAt),
        description: row.read(Firmwares.description),
        isBeta: row.read(Firmwares.isBeta),
        isPinned: row.read(Firmwares.isPinned),
        username: row.read(Firmwares.profiles)?.read(Profiles.username) ?? '',
      );

  /// The columns and relations [SavedFirmware.fromRow] reads.
  static final selection = <PostgrestSelectable<FirmwaresRow>>[
    Firmwares.id,
    Firmwares.userId,
    Firmwares.name,
    Firmwares.version,
    Firmwares.filePath,
    Firmwares.createdAt,
    Firmwares.updatedAt,
    Firmwares.description,
    Firmwares.isBeta,
    Firmwares.isPinned,
    Firmwares.profiles(Profiles.username),
  ];
}
