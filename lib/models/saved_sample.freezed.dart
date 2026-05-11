// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_sample.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedSample {

 String get id; String get userId; String get name; String get filePath; String get pcmFilePath; DateTime get createdAt; DateTime get updatedAt; String get slug; String get description; bool get isPublic;@JsonKey(readValue: _readUsername) String get username;@JsonKey(readValue: _readStarCount) int get starCount; bool get isStarred; List<double> get slicePoints; int get baseNote; int get fineTune; bool get pitched; List<int> get sliceNotes; int get loopMode; String? get contentHash;
/// Create a copy of SavedSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedSampleCopyWith<SavedSample> get copyWith => _$SavedSampleCopyWithImpl<SavedSample>(this as SavedSample, _$identity);

  /// Serializes this SavedSample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedSample&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.pcmFilePath, pcmFilePath) || other.pcmFilePath == pcmFilePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.username, username) || other.username == username)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&const DeepCollectionEquality().equals(other.slicePoints, slicePoints)&&(identical(other.baseNote, baseNote) || other.baseNote == baseNote)&&(identical(other.fineTune, fineTune) || other.fineTune == fineTune)&&(identical(other.pitched, pitched) || other.pitched == pitched)&&const DeepCollectionEquality().equals(other.sliceNotes, sliceNotes)&&(identical(other.loopMode, loopMode) || other.loopMode == loopMode)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,filePath,pcmFilePath,createdAt,updatedAt,slug,description,isPublic,username,starCount,isStarred,const DeepCollectionEquality().hash(slicePoints),baseNote,fineTune,pitched,const DeepCollectionEquality().hash(sliceNotes),loopMode,contentHash]);

@override
String toString() {
  return 'SavedSample(id: $id, userId: $userId, name: $name, filePath: $filePath, pcmFilePath: $pcmFilePath, createdAt: $createdAt, updatedAt: $updatedAt, slug: $slug, description: $description, isPublic: $isPublic, username: $username, starCount: $starCount, isStarred: $isStarred, slicePoints: $slicePoints, baseNote: $baseNote, fineTune: $fineTune, pitched: $pitched, sliceNotes: $sliceNotes, loopMode: $loopMode, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class $SavedSampleCopyWith<$Res>  {
  factory $SavedSampleCopyWith(SavedSample value, $Res Function(SavedSample) _then) = _$SavedSampleCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String filePath, String pcmFilePath, DateTime createdAt, DateTime updatedAt, String slug, String description, bool isPublic,@JsonKey(readValue: _readUsername) String username,@JsonKey(readValue: _readStarCount) int starCount, bool isStarred, List<double> slicePoints, int baseNote, int fineTune, bool pitched, List<int> sliceNotes, int loopMode, String? contentHash
});




}
/// @nodoc
class _$SavedSampleCopyWithImpl<$Res>
    implements $SavedSampleCopyWith<$Res> {
  _$SavedSampleCopyWithImpl(this._self, this._then);

  final SavedSample _self;
  final $Res Function(SavedSample) _then;

/// Create a copy of SavedSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? pcmFilePath = null,Object? createdAt = null,Object? updatedAt = null,Object? slug = null,Object? description = null,Object? isPublic = null,Object? username = null,Object? starCount = null,Object? isStarred = null,Object? slicePoints = null,Object? baseNote = null,Object? fineTune = null,Object? pitched = null,Object? sliceNotes = null,Object? loopMode = null,Object? contentHash = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,pcmFilePath: null == pcmFilePath ? _self.pcmFilePath : pcmFilePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,slicePoints: null == slicePoints ? _self.slicePoints : slicePoints // ignore: cast_nullable_to_non_nullable
as List<double>,baseNote: null == baseNote ? _self.baseNote : baseNote // ignore: cast_nullable_to_non_nullable
as int,fineTune: null == fineTune ? _self.fineTune : fineTune // ignore: cast_nullable_to_non_nullable
as int,pitched: null == pitched ? _self.pitched : pitched // ignore: cast_nullable_to_non_nullable
as bool,sliceNotes: null == sliceNotes ? _self.sliceNotes : sliceNotes // ignore: cast_nullable_to_non_nullable
as List<int>,loopMode: null == loopMode ? _self.loopMode : loopMode // ignore: cast_nullable_to_non_nullable
as int,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedSample].
extension SavedSamplePatterns on SavedSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedSample value)  $default,){
final _that = this;
switch (_that) {
case _SavedSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedSample value)?  $default,){
final _that = this;
switch (_that) {
case _SavedSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String filePath,  String pcmFilePath,  DateTime createdAt,  DateTime updatedAt,  String slug,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes,  int loopMode,  String? contentHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedSample() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.createdAt,_that.updatedAt,_that.slug,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes,_that.loopMode,_that.contentHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String filePath,  String pcmFilePath,  DateTime createdAt,  DateTime updatedAt,  String slug,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes,  int loopMode,  String? contentHash)  $default,) {final _that = this;
switch (_that) {
case _SavedSample():
return $default(_that.id,_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.createdAt,_that.updatedAt,_that.slug,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes,_that.loopMode,_that.contentHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String filePath,  String pcmFilePath,  DateTime createdAt,  DateTime updatedAt,  String slug,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes,  int loopMode,  String? contentHash)?  $default,) {final _that = this;
switch (_that) {
case _SavedSample() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.createdAt,_that.updatedAt,_that.slug,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes,_that.loopMode,_that.contentHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedSample implements SavedSample {
  const _SavedSample({required this.id, required this.userId, required this.name, required this.filePath, required this.pcmFilePath, required this.createdAt, required this.updatedAt, this.slug = '', this.description = '', this.isPublic = false, @JsonKey(readValue: _readUsername) this.username = '', @JsonKey(readValue: _readStarCount) this.starCount = 0, this.isStarred = false, final  List<double> slicePoints = defaultSlicePoints, this.baseNote = 60, this.fineTune = 0, this.pitched = false, final  List<int> sliceNotes = defaultSliceNotes, this.loopMode = 0, this.contentHash}): _slicePoints = slicePoints,_sliceNotes = sliceNotes;
  factory _SavedSample.fromJson(Map<String, dynamic> json) => _$SavedSampleFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String filePath;
@override final  String pcmFilePath;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  String slug;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override@JsonKey(readValue: _readUsername) final  String username;
@override@JsonKey(readValue: _readStarCount) final  int starCount;
@override@JsonKey() final  bool isStarred;
 final  List<double> _slicePoints;
@override@JsonKey() List<double> get slicePoints {
  if (_slicePoints is EqualUnmodifiableListView) return _slicePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slicePoints);
}

@override@JsonKey() final  int baseNote;
@override@JsonKey() final  int fineTune;
@override@JsonKey() final  bool pitched;
 final  List<int> _sliceNotes;
@override@JsonKey() List<int> get sliceNotes {
  if (_sliceNotes is EqualUnmodifiableListView) return _sliceNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sliceNotes);
}

@override@JsonKey() final  int loopMode;
@override final  String? contentHash;

/// Create a copy of SavedSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedSampleCopyWith<_SavedSample> get copyWith => __$SavedSampleCopyWithImpl<_SavedSample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedSampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedSample&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.pcmFilePath, pcmFilePath) || other.pcmFilePath == pcmFilePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.username, username) || other.username == username)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&const DeepCollectionEquality().equals(other._slicePoints, _slicePoints)&&(identical(other.baseNote, baseNote) || other.baseNote == baseNote)&&(identical(other.fineTune, fineTune) || other.fineTune == fineTune)&&(identical(other.pitched, pitched) || other.pitched == pitched)&&const DeepCollectionEquality().equals(other._sliceNotes, _sliceNotes)&&(identical(other.loopMode, loopMode) || other.loopMode == loopMode)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,filePath,pcmFilePath,createdAt,updatedAt,slug,description,isPublic,username,starCount,isStarred,const DeepCollectionEquality().hash(_slicePoints),baseNote,fineTune,pitched,const DeepCollectionEquality().hash(_sliceNotes),loopMode,contentHash]);

@override
String toString() {
  return 'SavedSample(id: $id, userId: $userId, name: $name, filePath: $filePath, pcmFilePath: $pcmFilePath, createdAt: $createdAt, updatedAt: $updatedAt, slug: $slug, description: $description, isPublic: $isPublic, username: $username, starCount: $starCount, isStarred: $isStarred, slicePoints: $slicePoints, baseNote: $baseNote, fineTune: $fineTune, pitched: $pitched, sliceNotes: $sliceNotes, loopMode: $loopMode, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class _$SavedSampleCopyWith<$Res> implements $SavedSampleCopyWith<$Res> {
  factory _$SavedSampleCopyWith(_SavedSample value, $Res Function(_SavedSample) _then) = __$SavedSampleCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String filePath, String pcmFilePath, DateTime createdAt, DateTime updatedAt, String slug, String description, bool isPublic,@JsonKey(readValue: _readUsername) String username,@JsonKey(readValue: _readStarCount) int starCount, bool isStarred, List<double> slicePoints, int baseNote, int fineTune, bool pitched, List<int> sliceNotes, int loopMode, String? contentHash
});




}
/// @nodoc
class __$SavedSampleCopyWithImpl<$Res>
    implements _$SavedSampleCopyWith<$Res> {
  __$SavedSampleCopyWithImpl(this._self, this._then);

  final _SavedSample _self;
  final $Res Function(_SavedSample) _then;

/// Create a copy of SavedSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? pcmFilePath = null,Object? createdAt = null,Object? updatedAt = null,Object? slug = null,Object? description = null,Object? isPublic = null,Object? username = null,Object? starCount = null,Object? isStarred = null,Object? slicePoints = null,Object? baseNote = null,Object? fineTune = null,Object? pitched = null,Object? sliceNotes = null,Object? loopMode = null,Object? contentHash = freezed,}) {
  return _then(_SavedSample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,pcmFilePath: null == pcmFilePath ? _self.pcmFilePath : pcmFilePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,slicePoints: null == slicePoints ? _self._slicePoints : slicePoints // ignore: cast_nullable_to_non_nullable
as List<double>,baseNote: null == baseNote ? _self.baseNote : baseNote // ignore: cast_nullable_to_non_nullable
as int,fineTune: null == fineTune ? _self.fineTune : fineTune // ignore: cast_nullable_to_non_nullable
as int,pitched: null == pitched ? _self.pitched : pitched // ignore: cast_nullable_to_non_nullable
as bool,sliceNotes: null == sliceNotes ? _self._sliceNotes : sliceNotes // ignore: cast_nullable_to_non_nullable
as List<int>,loopMode: null == loopMode ? _self.loopMode : loopMode // ignore: cast_nullable_to_non_nullable
as int,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
