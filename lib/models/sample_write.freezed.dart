// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sample_write.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SampleWrite {

 String get userId; String get name; String get filePath; String get pcmFilePath; String get description; bool get isPublic; List<double> get slicePoints; int get baseNote; int get fineTune; bool get pitched; List<int> get sliceNotes;
/// Create a copy of SampleWrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SampleWriteCopyWith<SampleWrite> get copyWith => _$SampleWriteCopyWithImpl<SampleWrite>(this as SampleWrite, _$identity);

  /// Serializes this SampleWrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SampleWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.pcmFilePath, pcmFilePath) || other.pcmFilePath == pcmFilePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other.slicePoints, slicePoints)&&(identical(other.baseNote, baseNote) || other.baseNote == baseNote)&&(identical(other.fineTune, fineTune) || other.fineTune == fineTune)&&(identical(other.pitched, pitched) || other.pitched == pitched)&&const DeepCollectionEquality().equals(other.sliceNotes, sliceNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,filePath,pcmFilePath,description,isPublic,const DeepCollectionEquality().hash(slicePoints),baseNote,fineTune,pitched,const DeepCollectionEquality().hash(sliceNotes));

@override
String toString() {
  return 'SampleWrite(userId: $userId, name: $name, filePath: $filePath, pcmFilePath: $pcmFilePath, description: $description, isPublic: $isPublic, slicePoints: $slicePoints, baseNote: $baseNote, fineTune: $fineTune, pitched: $pitched, sliceNotes: $sliceNotes)';
}


}

/// @nodoc
abstract mixin class $SampleWriteCopyWith<$Res>  {
  factory $SampleWriteCopyWith(SampleWrite value, $Res Function(SampleWrite) _then) = _$SampleWriteCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String filePath, String pcmFilePath, String description, bool isPublic, List<double> slicePoints, int baseNote, int fineTune, bool pitched, List<int> sliceNotes
});




}
/// @nodoc
class _$SampleWriteCopyWithImpl<$Res>
    implements $SampleWriteCopyWith<$Res> {
  _$SampleWriteCopyWithImpl(this._self, this._then);

  final SampleWrite _self;
  final $Res Function(SampleWrite) _then;

/// Create a copy of SampleWrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? filePath = null,Object? pcmFilePath = null,Object? description = null,Object? isPublic = null,Object? slicePoints = null,Object? baseNote = null,Object? fineTune = null,Object? pitched = null,Object? sliceNotes = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,pcmFilePath: null == pcmFilePath ? _self.pcmFilePath : pcmFilePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,slicePoints: null == slicePoints ? _self.slicePoints : slicePoints // ignore: cast_nullable_to_non_nullable
as List<double>,baseNote: null == baseNote ? _self.baseNote : baseNote // ignore: cast_nullable_to_non_nullable
as int,fineTune: null == fineTune ? _self.fineTune : fineTune // ignore: cast_nullable_to_non_nullable
as int,pitched: null == pitched ? _self.pitched : pitched // ignore: cast_nullable_to_non_nullable
as bool,sliceNotes: null == sliceNotes ? _self.sliceNotes : sliceNotes // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [SampleWrite].
extension SampleWritePatterns on SampleWrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SampleWrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SampleWrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SampleWrite value)  $default,){
final _that = this;
switch (_that) {
case _SampleWrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SampleWrite value)?  $default,){
final _that = this;
switch (_that) {
case _SampleWrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String filePath,  String pcmFilePath,  String description,  bool isPublic,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SampleWrite() when $default != null:
return $default(_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.description,_that.isPublic,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String filePath,  String pcmFilePath,  String description,  bool isPublic,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes)  $default,) {final _that = this;
switch (_that) {
case _SampleWrite():
return $default(_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.description,_that.isPublic,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String filePath,  String pcmFilePath,  String description,  bool isPublic,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes)?  $default,) {final _that = this;
switch (_that) {
case _SampleWrite() when $default != null:
return $default(_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.description,_that.isPublic,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SampleWrite implements SampleWrite {
  const _SampleWrite({required this.userId, required this.name, required this.filePath, required this.pcmFilePath, this.description = '', this.isPublic = false, final  List<double> slicePoints = defaultSlicePoints, this.baseNote = 60, this.fineTune = 0, this.pitched = false, final  List<int> sliceNotes = defaultSliceNotes}): _slicePoints = slicePoints,_sliceNotes = sliceNotes;
  factory _SampleWrite.fromJson(Map<String, dynamic> json) => _$SampleWriteFromJson(json);

@override final  String userId;
@override final  String name;
@override final  String filePath;
@override final  String pcmFilePath;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
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


/// Create a copy of SampleWrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SampleWriteCopyWith<_SampleWrite> get copyWith => __$SampleWriteCopyWithImpl<_SampleWrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SampleWriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SampleWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.pcmFilePath, pcmFilePath) || other.pcmFilePath == pcmFilePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other._slicePoints, _slicePoints)&&(identical(other.baseNote, baseNote) || other.baseNote == baseNote)&&(identical(other.fineTune, fineTune) || other.fineTune == fineTune)&&(identical(other.pitched, pitched) || other.pitched == pitched)&&const DeepCollectionEquality().equals(other._sliceNotes, _sliceNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,filePath,pcmFilePath,description,isPublic,const DeepCollectionEquality().hash(_slicePoints),baseNote,fineTune,pitched,const DeepCollectionEquality().hash(_sliceNotes));

@override
String toString() {
  return 'SampleWrite(userId: $userId, name: $name, filePath: $filePath, pcmFilePath: $pcmFilePath, description: $description, isPublic: $isPublic, slicePoints: $slicePoints, baseNote: $baseNote, fineTune: $fineTune, pitched: $pitched, sliceNotes: $sliceNotes)';
}


}

/// @nodoc
abstract mixin class _$SampleWriteCopyWith<$Res> implements $SampleWriteCopyWith<$Res> {
  factory _$SampleWriteCopyWith(_SampleWrite value, $Res Function(_SampleWrite) _then) = __$SampleWriteCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String filePath, String pcmFilePath, String description, bool isPublic, List<double> slicePoints, int baseNote, int fineTune, bool pitched, List<int> sliceNotes
});




}
/// @nodoc
class __$SampleWriteCopyWithImpl<$Res>
    implements _$SampleWriteCopyWith<$Res> {
  __$SampleWriteCopyWithImpl(this._self, this._then);

  final _SampleWrite _self;
  final $Res Function(_SampleWrite) _then;

/// Create a copy of SampleWrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? filePath = null,Object? pcmFilePath = null,Object? description = null,Object? isPublic = null,Object? slicePoints = null,Object? baseNote = null,Object? fineTune = null,Object? pitched = null,Object? sliceNotes = null,}) {
  return _then(_SampleWrite(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,pcmFilePath: null == pcmFilePath ? _self.pcmFilePath : pcmFilePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,slicePoints: null == slicePoints ? _self._slicePoints : slicePoints // ignore: cast_nullable_to_non_nullable
as List<double>,baseNote: null == baseNote ? _self.baseNote : baseNote // ignore: cast_nullable_to_non_nullable
as int,fineTune: null == fineTune ? _self.fineTune : fineTune // ignore: cast_nullable_to_non_nullable
as int,pitched: null == pitched ? _self.pitched : pitched // ignore: cast_nullable_to_non_nullable
as bool,sliceNotes: null == sliceNotes ? _self._sliceNotes : sliceNotes // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
