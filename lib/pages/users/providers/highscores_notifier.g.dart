// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highscores_notifier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserHighscore _$UserHighscoreFromJson(Map<String, dynamic> json) =>
    _UserHighscore(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      totalStars: (json['total_stars'] as num).toInt(),
      totalUploads: (json['total_uploads'] as num).toInt(),
    );

Map<String, dynamic> _$UserHighscoreToJson(_UserHighscore instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'total_stars': instance.totalStars,
      'total_uploads': instance.totalUploads,
    };
