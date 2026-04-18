// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dumps_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DumpsState {

 List<SavedDump> get dumps; bool get isLoading; String? get errorMessage;
/// Create a copy of DumpsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DumpsStateCopyWith<DumpsState> get copyWith => _$DumpsStateCopyWithImpl<DumpsState>(this as DumpsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DumpsState&&const DeepCollectionEquality().equals(other.dumps, dumps)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dumps),isLoading,errorMessage);

@override
String toString() {
  return 'DumpsState(dumps: $dumps, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $DumpsStateCopyWith<$Res>  {
  factory $DumpsStateCopyWith(DumpsState value, $Res Function(DumpsState) _then) = _$DumpsStateCopyWithImpl;
@useResult
$Res call({
 List<SavedDump> dumps, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$DumpsStateCopyWithImpl<$Res>
    implements $DumpsStateCopyWith<$Res> {
  _$DumpsStateCopyWithImpl(this._self, this._then);

  final DumpsState _self;
  final $Res Function(DumpsState) _then;

/// Create a copy of DumpsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dumps = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
dumps: null == dumps ? _self.dumps : dumps // ignore: cast_nullable_to_non_nullable
as List<SavedDump>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DumpsState].
extension DumpsStatePatterns on DumpsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DumpsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DumpsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DumpsState value)  $default,){
final _that = this;
switch (_that) {
case _DumpsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DumpsState value)?  $default,){
final _that = this;
switch (_that) {
case _DumpsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SavedDump> dumps,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DumpsState() when $default != null:
return $default(_that.dumps,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SavedDump> dumps,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _DumpsState():
return $default(_that.dumps,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SavedDump> dumps,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _DumpsState() when $default != null:
return $default(_that.dumps,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DumpsState implements DumpsState {
  const _DumpsState({final  List<SavedDump> dumps = const [], this.isLoading = false, this.errorMessage}): _dumps = dumps;
  

 final  List<SavedDump> _dumps;
@override@JsonKey() List<SavedDump> get dumps {
  if (_dumps is EqualUnmodifiableListView) return _dumps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dumps);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of DumpsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DumpsStateCopyWith<_DumpsState> get copyWith => __$DumpsStateCopyWithImpl<_DumpsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DumpsState&&const DeepCollectionEquality().equals(other._dumps, _dumps)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dumps),isLoading,errorMessage);

@override
String toString() {
  return 'DumpsState(dumps: $dumps, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$DumpsStateCopyWith<$Res> implements $DumpsStateCopyWith<$Res> {
  factory _$DumpsStateCopyWith(_DumpsState value, $Res Function(_DumpsState) _then) = __$DumpsStateCopyWithImpl;
@override @useResult
$Res call({
 List<SavedDump> dumps, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$DumpsStateCopyWithImpl<$Res>
    implements _$DumpsStateCopyWith<$Res> {
  __$DumpsStateCopyWithImpl(this._self, this._then);

  final _DumpsState _self;
  final $Res Function(_DumpsState) _then;

/// Create a copy of DumpsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dumps = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_DumpsState(
dumps: null == dumps ? _self._dumps : dumps // ignore: cast_nullable_to_non_nullable
as List<SavedDump>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
