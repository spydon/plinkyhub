// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_presets_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavedPresetsState {

 List<SavedPreset> get userPresets; List<SavedPreset> get publicPresets; bool get isLoading; String? get errorMessage;
/// Create a copy of SavedPresetsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPresetsStateCopyWith<SavedPresetsState> get copyWith => _$SavedPresetsStateCopyWithImpl<SavedPresetsState>(this as SavedPresetsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPresetsState&&const DeepCollectionEquality().equals(other.userPresets, userPresets)&&const DeepCollectionEquality().equals(other.publicPresets, publicPresets)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userPresets),const DeepCollectionEquality().hash(publicPresets),isLoading,errorMessage);

@override
String toString() {
  return 'SavedPresetsState(userPresets: $userPresets, publicPresets: $publicPresets, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SavedPresetsStateCopyWith<$Res>  {
  factory $SavedPresetsStateCopyWith(SavedPresetsState value, $Res Function(SavedPresetsState) _then) = _$SavedPresetsStateCopyWithImpl;
@useResult
$Res call({
 List<SavedPreset> userPresets, List<SavedPreset> publicPresets, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$SavedPresetsStateCopyWithImpl<$Res>
    implements $SavedPresetsStateCopyWith<$Res> {
  _$SavedPresetsStateCopyWithImpl(this._self, this._then);

  final SavedPresetsState _self;
  final $Res Function(SavedPresetsState) _then;

/// Create a copy of SavedPresetsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userPresets = null,Object? publicPresets = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
userPresets: null == userPresets ? _self.userPresets : userPresets // ignore: cast_nullable_to_non_nullable
as List<SavedPreset>,publicPresets: null == publicPresets ? _self.publicPresets : publicPresets // ignore: cast_nullable_to_non_nullable
as List<SavedPreset>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedPresetsState].
extension SavedPresetsStatePatterns on SavedPresetsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPresetsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPresetsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPresetsState value)  $default,){
final _that = this;
switch (_that) {
case _SavedPresetsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPresetsState value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPresetsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SavedPreset> userPresets,  List<SavedPreset> publicPresets,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPresetsState() when $default != null:
return $default(_that.userPresets,_that.publicPresets,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SavedPreset> userPresets,  List<SavedPreset> publicPresets,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SavedPresetsState():
return $default(_that.userPresets,_that.publicPresets,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SavedPreset> userPresets,  List<SavedPreset> publicPresets,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SavedPresetsState() when $default != null:
return $default(_that.userPresets,_that.publicPresets,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SavedPresetsState implements SavedPresetsState {
  const _SavedPresetsState({final  List<SavedPreset> userPresets = const [], final  List<SavedPreset> publicPresets = const [], this.isLoading = false, this.errorMessage}): _userPresets = userPresets,_publicPresets = publicPresets;
  

 final  List<SavedPreset> _userPresets;
@override@JsonKey() List<SavedPreset> get userPresets {
  if (_userPresets is EqualUnmodifiableListView) return _userPresets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userPresets);
}

 final  List<SavedPreset> _publicPresets;
@override@JsonKey() List<SavedPreset> get publicPresets {
  if (_publicPresets is EqualUnmodifiableListView) return _publicPresets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publicPresets);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of SavedPresetsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPresetsStateCopyWith<_SavedPresetsState> get copyWith => __$SavedPresetsStateCopyWithImpl<_SavedPresetsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPresetsState&&const DeepCollectionEquality().equals(other._userPresets, _userPresets)&&const DeepCollectionEquality().equals(other._publicPresets, _publicPresets)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userPresets),const DeepCollectionEquality().hash(_publicPresets),isLoading,errorMessage);

@override
String toString() {
  return 'SavedPresetsState(userPresets: $userPresets, publicPresets: $publicPresets, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SavedPresetsStateCopyWith<$Res> implements $SavedPresetsStateCopyWith<$Res> {
  factory _$SavedPresetsStateCopyWith(_SavedPresetsState value, $Res Function(_SavedPresetsState) _then) = __$SavedPresetsStateCopyWithImpl;
@override @useResult
$Res call({
 List<SavedPreset> userPresets, List<SavedPreset> publicPresets, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$SavedPresetsStateCopyWithImpl<$Res>
    implements _$SavedPresetsStateCopyWith<$Res> {
  __$SavedPresetsStateCopyWithImpl(this._self, this._then);

  final _SavedPresetsState _self;
  final $Res Function(_SavedPresetsState) _then;

/// Create a copy of SavedPresetsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userPresets = null,Object? publicPresets = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_SavedPresetsState(
userPresets: null == userPresets ? _self._userPresets : userPresets // ignore: cast_nullable_to_non_nullable
as List<SavedPreset>,publicPresets: null == publicPresets ? _self._publicPresets : publicPresets // ignore: cast_nullable_to_non_nullable
as List<SavedPreset>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
