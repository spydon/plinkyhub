// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pattern_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatternData {

 int get version; int get stepCount; int get scaleIndex; List<List<int>> get grid;
/// Create a copy of PatternData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatternDataCopyWith<PatternData> get copyWith => _$PatternDataCopyWithImpl<PatternData>(this as PatternData, _$identity);

  /// Serializes this PatternData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatternData&&(identical(other.version, version) || other.version == version)&&(identical(other.stepCount, stepCount) || other.stepCount == stepCount)&&(identical(other.scaleIndex, scaleIndex) || other.scaleIndex == scaleIndex)&&const DeepCollectionEquality().equals(other.grid, grid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,stepCount,scaleIndex,const DeepCollectionEquality().hash(grid));

@override
String toString() {
  return 'PatternData(version: $version, stepCount: $stepCount, scaleIndex: $scaleIndex, grid: $grid)';
}


}

/// @nodoc
abstract mixin class $PatternDataCopyWith<$Res>  {
  factory $PatternDataCopyWith(PatternData value, $Res Function(PatternData) _then) = _$PatternDataCopyWithImpl;
@useResult
$Res call({
 int version, int stepCount, int scaleIndex, List<List<int>> grid
});




}
/// @nodoc
class _$PatternDataCopyWithImpl<$Res>
    implements $PatternDataCopyWith<$Res> {
  _$PatternDataCopyWithImpl(this._self, this._then);

  final PatternData _self;
  final $Res Function(PatternData) _then;

/// Create a copy of PatternData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? stepCount = null,Object? scaleIndex = null,Object? grid = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,stepCount: null == stepCount ? _self.stepCount : stepCount // ignore: cast_nullable_to_non_nullable
as int,scaleIndex: null == scaleIndex ? _self.scaleIndex : scaleIndex // ignore: cast_nullable_to_non_nullable
as int,grid: null == grid ? _self.grid : grid // ignore: cast_nullable_to_non_nullable
as List<List<int>>,
  ));
}

}


/// Adds pattern-matching-related methods to [PatternData].
extension PatternDataPatterns on PatternData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatternData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatternData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatternData value)  $default,){
final _that = this;
switch (_that) {
case _PatternData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatternData value)?  $default,){
final _that = this;
switch (_that) {
case _PatternData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  int stepCount,  int scaleIndex,  List<List<int>> grid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatternData() when $default != null:
return $default(_that.version,_that.stepCount,_that.scaleIndex,_that.grid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  int stepCount,  int scaleIndex,  List<List<int>> grid)  $default,) {final _that = this;
switch (_that) {
case _PatternData():
return $default(_that.version,_that.stepCount,_that.scaleIndex,_that.grid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  int stepCount,  int scaleIndex,  List<List<int>> grid)?  $default,) {final _that = this;
switch (_that) {
case _PatternData() when $default != null:
return $default(_that.version,_that.stepCount,_that.scaleIndex,_that.grid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatternData implements PatternData {
  const _PatternData({this.version = 1, this.stepCount = 16, this.scaleIndex = 0, final  List<List<int>> grid = const []}): _grid = grid;
  factory _PatternData.fromJson(Map<String, dynamic> json) => _$PatternDataFromJson(json);

@override@JsonKey() final  int version;
@override@JsonKey() final  int stepCount;
@override@JsonKey() final  int scaleIndex;
 final  List<List<int>> _grid;
@override@JsonKey() List<List<int>> get grid {
  if (_grid is EqualUnmodifiableListView) return _grid;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_grid);
}


/// Create a copy of PatternData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatternDataCopyWith<_PatternData> get copyWith => __$PatternDataCopyWithImpl<_PatternData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatternDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatternData&&(identical(other.version, version) || other.version == version)&&(identical(other.stepCount, stepCount) || other.stepCount == stepCount)&&(identical(other.scaleIndex, scaleIndex) || other.scaleIndex == scaleIndex)&&const DeepCollectionEquality().equals(other._grid, _grid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,stepCount,scaleIndex,const DeepCollectionEquality().hash(_grid));

@override
String toString() {
  return 'PatternData(version: $version, stepCount: $stepCount, scaleIndex: $scaleIndex, grid: $grid)';
}


}

/// @nodoc
abstract mixin class _$PatternDataCopyWith<$Res> implements $PatternDataCopyWith<$Res> {
  factory _$PatternDataCopyWith(_PatternData value, $Res Function(_PatternData) _then) = __$PatternDataCopyWithImpl;
@override @useResult
$Res call({
 int version, int stepCount, int scaleIndex, List<List<int>> grid
});




}
/// @nodoc
class __$PatternDataCopyWithImpl<$Res>
    implements _$PatternDataCopyWith<$Res> {
  __$PatternDataCopyWithImpl(this._self, this._then);

  final _PatternData _self;
  final $Res Function(_PatternData) _then;

/// Create a copy of PatternData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? stepCount = null,Object? scaleIndex = null,Object? grid = null,}) {
  return _then(_PatternData(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,stepCount: null == stepCount ? _self.stepCount : stepCount // ignore: cast_nullable_to_non_nullable
as int,scaleIndex: null == scaleIndex ? _self.scaleIndex : scaleIndex // ignore: cast_nullable_to_non_nullable
as int,grid: null == grid ? _self._grid : grid // ignore: cast_nullable_to_non_nullable
as List<List<int>>,
  ));
}


}

// dart format on
