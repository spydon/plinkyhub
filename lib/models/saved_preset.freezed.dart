// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedPreset {

 String get id; String get userId; String get name; String get category; String get presetData; DateTime get createdAt; DateTime get updatedAt; String get slug; String get description; bool get isPublic;@JsonKey(readValue: _readUsername) String get username;@JsonKey(readValue: _readStarCount) int get starCount; bool get isStarred; String get youtubeUrl; String? get sampleId;@JsonKey(readValue: _readSampleName) String? get sampleName;@JsonKey(readValue: _readSampleSlug) String? get sampleSlug;@JsonKey(readValue: _readSampleUsername) String? get sampleUsername;
/// Create a copy of SavedPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPresetCopyWith<SavedPreset> get copyWith => _$SavedPresetCopyWithImpl<SavedPreset>(this as SavedPreset, _$identity);

  /// Serializes this SavedPreset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPreset&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.presetData, presetData) || other.presetData == presetData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.username, username) || other.username == username)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.sampleName, sampleName) || other.sampleName == sampleName)&&(identical(other.sampleSlug, sampleSlug) || other.sampleSlug == sampleSlug)&&(identical(other.sampleUsername, sampleUsername) || other.sampleUsername == sampleUsername));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,category,presetData,createdAt,updatedAt,slug,description,isPublic,username,starCount,isStarred,youtubeUrl,sampleId,sampleName,sampleSlug,sampleUsername);

@override
String toString() {
  return 'SavedPreset(id: $id, userId: $userId, name: $name, category: $category, presetData: $presetData, createdAt: $createdAt, updatedAt: $updatedAt, slug: $slug, description: $description, isPublic: $isPublic, username: $username, starCount: $starCount, isStarred: $isStarred, youtubeUrl: $youtubeUrl, sampleId: $sampleId, sampleName: $sampleName, sampleSlug: $sampleSlug, sampleUsername: $sampleUsername)';
}


}

/// @nodoc
abstract mixin class $SavedPresetCopyWith<$Res>  {
  factory $SavedPresetCopyWith(SavedPreset value, $Res Function(SavedPreset) _then) = _$SavedPresetCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String category, String presetData, DateTime createdAt, DateTime updatedAt, String slug, String description, bool isPublic,@JsonKey(readValue: _readUsername) String username,@JsonKey(readValue: _readStarCount) int starCount, bool isStarred, String youtubeUrl, String? sampleId,@JsonKey(readValue: _readSampleName) String? sampleName,@JsonKey(readValue: _readSampleSlug) String? sampleSlug,@JsonKey(readValue: _readSampleUsername) String? sampleUsername
});




}
/// @nodoc
class _$SavedPresetCopyWithImpl<$Res>
    implements $SavedPresetCopyWith<$Res> {
  _$SavedPresetCopyWithImpl(this._self, this._then);

  final SavedPreset _self;
  final $Res Function(SavedPreset) _then;

/// Create a copy of SavedPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? category = null,Object? presetData = null,Object? createdAt = null,Object? updatedAt = null,Object? slug = null,Object? description = null,Object? isPublic = null,Object? username = null,Object? starCount = null,Object? isStarred = null,Object? youtubeUrl = null,Object? sampleId = freezed,Object? sampleName = freezed,Object? sampleSlug = freezed,Object? sampleUsername = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,presetData: null == presetData ? _self.presetData : presetData // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,sampleName: freezed == sampleName ? _self.sampleName : sampleName // ignore: cast_nullable_to_non_nullable
as String?,sampleSlug: freezed == sampleSlug ? _self.sampleSlug : sampleSlug // ignore: cast_nullable_to_non_nullable
as String?,sampleUsername: freezed == sampleUsername ? _self.sampleUsername : sampleUsername // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedPreset].
extension SavedPresetPatterns on SavedPreset {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPreset() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPreset value)  $default,){
final _that = this;
switch (_that) {
case _SavedPreset():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPreset value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPreset() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String category,  String presetData,  DateTime createdAt,  DateTime updatedAt,  String slug,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  String youtubeUrl,  String? sampleId, @JsonKey(readValue: _readSampleName)  String? sampleName, @JsonKey(readValue: _readSampleSlug)  String? sampleSlug, @JsonKey(readValue: _readSampleUsername)  String? sampleUsername)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPreset() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.category,_that.presetData,_that.createdAt,_that.updatedAt,_that.slug,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.youtubeUrl,_that.sampleId,_that.sampleName,_that.sampleSlug,_that.sampleUsername);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String category,  String presetData,  DateTime createdAt,  DateTime updatedAt,  String slug,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  String youtubeUrl,  String? sampleId, @JsonKey(readValue: _readSampleName)  String? sampleName, @JsonKey(readValue: _readSampleSlug)  String? sampleSlug, @JsonKey(readValue: _readSampleUsername)  String? sampleUsername)  $default,) {final _that = this;
switch (_that) {
case _SavedPreset():
return $default(_that.id,_that.userId,_that.name,_that.category,_that.presetData,_that.createdAt,_that.updatedAt,_that.slug,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.youtubeUrl,_that.sampleId,_that.sampleName,_that.sampleSlug,_that.sampleUsername);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String category,  String presetData,  DateTime createdAt,  DateTime updatedAt,  String slug,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  String youtubeUrl,  String? sampleId, @JsonKey(readValue: _readSampleName)  String? sampleName, @JsonKey(readValue: _readSampleSlug)  String? sampleSlug, @JsonKey(readValue: _readSampleUsername)  String? sampleUsername)?  $default,) {final _that = this;
switch (_that) {
case _SavedPreset() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.category,_that.presetData,_that.createdAt,_that.updatedAt,_that.slug,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.youtubeUrl,_that.sampleId,_that.sampleName,_that.sampleSlug,_that.sampleUsername);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedPreset implements SavedPreset {
  const _SavedPreset({required this.id, required this.userId, required this.name, required this.category, required this.presetData, required this.createdAt, required this.updatedAt, this.slug = '', this.description = '', this.isPublic = false, @JsonKey(readValue: _readUsername) this.username = '', @JsonKey(readValue: _readStarCount) this.starCount = 0, this.isStarred = false, this.youtubeUrl = '', this.sampleId, @JsonKey(readValue: _readSampleName) this.sampleName, @JsonKey(readValue: _readSampleSlug) this.sampleSlug, @JsonKey(readValue: _readSampleUsername) this.sampleUsername});
  factory _SavedPreset.fromJson(Map<String, dynamic> json) => _$SavedPresetFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String category;
@override final  String presetData;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  String slug;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override@JsonKey(readValue: _readUsername) final  String username;
@override@JsonKey(readValue: _readStarCount) final  int starCount;
@override@JsonKey() final  bool isStarred;
@override@JsonKey() final  String youtubeUrl;
@override final  String? sampleId;
@override@JsonKey(readValue: _readSampleName) final  String? sampleName;
@override@JsonKey(readValue: _readSampleSlug) final  String? sampleSlug;
@override@JsonKey(readValue: _readSampleUsername) final  String? sampleUsername;

/// Create a copy of SavedPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPresetCopyWith<_SavedPreset> get copyWith => __$SavedPresetCopyWithImpl<_SavedPreset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedPresetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPreset&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.presetData, presetData) || other.presetData == presetData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.username, username) || other.username == username)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.sampleName, sampleName) || other.sampleName == sampleName)&&(identical(other.sampleSlug, sampleSlug) || other.sampleSlug == sampleSlug)&&(identical(other.sampleUsername, sampleUsername) || other.sampleUsername == sampleUsername));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,category,presetData,createdAt,updatedAt,slug,description,isPublic,username,starCount,isStarred,youtubeUrl,sampleId,sampleName,sampleSlug,sampleUsername);

@override
String toString() {
  return 'SavedPreset(id: $id, userId: $userId, name: $name, category: $category, presetData: $presetData, createdAt: $createdAt, updatedAt: $updatedAt, slug: $slug, description: $description, isPublic: $isPublic, username: $username, starCount: $starCount, isStarred: $isStarred, youtubeUrl: $youtubeUrl, sampleId: $sampleId, sampleName: $sampleName, sampleSlug: $sampleSlug, sampleUsername: $sampleUsername)';
}


}

/// @nodoc
abstract mixin class _$SavedPresetCopyWith<$Res> implements $SavedPresetCopyWith<$Res> {
  factory _$SavedPresetCopyWith(_SavedPreset value, $Res Function(_SavedPreset) _then) = __$SavedPresetCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String category, String presetData, DateTime createdAt, DateTime updatedAt, String slug, String description, bool isPublic,@JsonKey(readValue: _readUsername) String username,@JsonKey(readValue: _readStarCount) int starCount, bool isStarred, String youtubeUrl, String? sampleId,@JsonKey(readValue: _readSampleName) String? sampleName,@JsonKey(readValue: _readSampleSlug) String? sampleSlug,@JsonKey(readValue: _readSampleUsername) String? sampleUsername
});




}
/// @nodoc
class __$SavedPresetCopyWithImpl<$Res>
    implements _$SavedPresetCopyWith<$Res> {
  __$SavedPresetCopyWithImpl(this._self, this._then);

  final _SavedPreset _self;
  final $Res Function(_SavedPreset) _then;

/// Create a copy of SavedPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? category = null,Object? presetData = null,Object? createdAt = null,Object? updatedAt = null,Object? slug = null,Object? description = null,Object? isPublic = null,Object? username = null,Object? starCount = null,Object? isStarred = null,Object? youtubeUrl = null,Object? sampleId = freezed,Object? sampleName = freezed,Object? sampleSlug = freezed,Object? sampleUsername = freezed,}) {
  return _then(_SavedPreset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,presetData: null == presetData ? _self.presetData : presetData // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,sampleName: freezed == sampleName ? _self.sampleName : sampleName // ignore: cast_nullable_to_non_nullable
as String?,sampleSlug: freezed == sampleSlug ? _self.sampleSlug : sampleSlug // ignore: cast_nullable_to_non_nullable
as String?,sampleUsername: freezed == sampleUsername ? _self.sampleUsername : sampleUsername // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
