// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_patterns_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavedPatternsState {

 List<SavedPattern> get userPatterns; List<SavedPattern> get starredPatterns; List<SavedPattern> get publicPatterns; bool get isLoading; String? get errorMessage;
/// Create a copy of SavedPatternsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPatternsStateCopyWith<SavedPatternsState> get copyWith => _$SavedPatternsStateCopyWithImpl<SavedPatternsState>(this as SavedPatternsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPatternsState&&const DeepCollectionEquality().equals(other.userPatterns, userPatterns)&&const DeepCollectionEquality().equals(other.starredPatterns, starredPatterns)&&const DeepCollectionEquality().equals(other.publicPatterns, publicPatterns)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userPatterns),const DeepCollectionEquality().hash(starredPatterns),const DeepCollectionEquality().hash(publicPatterns),isLoading,errorMessage);

@override
String toString() {
  return 'SavedPatternsState(userPatterns: $userPatterns, starredPatterns: $starredPatterns, publicPatterns: $publicPatterns, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SavedPatternsStateCopyWith<$Res>  {
  factory $SavedPatternsStateCopyWith(SavedPatternsState value, $Res Function(SavedPatternsState) _then) = _$SavedPatternsStateCopyWithImpl;
@useResult
$Res call({
 List<SavedPattern> userPatterns, List<SavedPattern> starredPatterns, List<SavedPattern> publicPatterns, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$SavedPatternsStateCopyWithImpl<$Res>
    implements $SavedPatternsStateCopyWith<$Res> {
  _$SavedPatternsStateCopyWithImpl(this._self, this._then);

  final SavedPatternsState _self;
  final $Res Function(SavedPatternsState) _then;

/// Create a copy of SavedPatternsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userPatterns = null,Object? starredPatterns = null,Object? publicPatterns = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
userPatterns: null == userPatterns ? _self.userPatterns : userPatterns // ignore: cast_nullable_to_non_nullable
as List<SavedPattern>,starredPatterns: null == starredPatterns ? _self.starredPatterns : starredPatterns // ignore: cast_nullable_to_non_nullable
as List<SavedPattern>,publicPatterns: null == publicPatterns ? _self.publicPatterns : publicPatterns // ignore: cast_nullable_to_non_nullable
as List<SavedPattern>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedPatternsState].
extension SavedPatternsStatePatterns on SavedPatternsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPatternsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPatternsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPatternsState value)  $default,){
final _that = this;
switch (_that) {
case _SavedPatternsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPatternsState value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPatternsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SavedPattern> userPatterns,  List<SavedPattern> starredPatterns,  List<SavedPattern> publicPatterns,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPatternsState() when $default != null:
return $default(_that.userPatterns,_that.starredPatterns,_that.publicPatterns,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SavedPattern> userPatterns,  List<SavedPattern> starredPatterns,  List<SavedPattern> publicPatterns,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SavedPatternsState():
return $default(_that.userPatterns,_that.starredPatterns,_that.publicPatterns,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SavedPattern> userPatterns,  List<SavedPattern> starredPatterns,  List<SavedPattern> publicPatterns,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SavedPatternsState() when $default != null:
return $default(_that.userPatterns,_that.starredPatterns,_that.publicPatterns,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SavedPatternsState implements SavedPatternsState {
  const _SavedPatternsState({final  List<SavedPattern> userPatterns = const [], final  List<SavedPattern> starredPatterns = const [], final  List<SavedPattern> publicPatterns = const [], this.isLoading = false, this.errorMessage}): _userPatterns = userPatterns,_starredPatterns = starredPatterns,_publicPatterns = publicPatterns;
  

 final  List<SavedPattern> _userPatterns;
@override@JsonKey() List<SavedPattern> get userPatterns {
  if (_userPatterns is EqualUnmodifiableListView) return _userPatterns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userPatterns);
}

 final  List<SavedPattern> _starredPatterns;
@override@JsonKey() List<SavedPattern> get starredPatterns {
  if (_starredPatterns is EqualUnmodifiableListView) return _starredPatterns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_starredPatterns);
}

 final  List<SavedPattern> _publicPatterns;
@override@JsonKey() List<SavedPattern> get publicPatterns {
  if (_publicPatterns is EqualUnmodifiableListView) return _publicPatterns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publicPatterns);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of SavedPatternsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPatternsStateCopyWith<_SavedPatternsState> get copyWith => __$SavedPatternsStateCopyWithImpl<_SavedPatternsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPatternsState&&const DeepCollectionEquality().equals(other._userPatterns, _userPatterns)&&const DeepCollectionEquality().equals(other._starredPatterns, _starredPatterns)&&const DeepCollectionEquality().equals(other._publicPatterns, _publicPatterns)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userPatterns),const DeepCollectionEquality().hash(_starredPatterns),const DeepCollectionEquality().hash(_publicPatterns),isLoading,errorMessage);

@override
String toString() {
  return 'SavedPatternsState(userPatterns: $userPatterns, starredPatterns: $starredPatterns, publicPatterns: $publicPatterns, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SavedPatternsStateCopyWith<$Res> implements $SavedPatternsStateCopyWith<$Res> {
  factory _$SavedPatternsStateCopyWith(_SavedPatternsState value, $Res Function(_SavedPatternsState) _then) = __$SavedPatternsStateCopyWithImpl;
@override @useResult
$Res call({
 List<SavedPattern> userPatterns, List<SavedPattern> starredPatterns, List<SavedPattern> publicPatterns, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$SavedPatternsStateCopyWithImpl<$Res>
    implements _$SavedPatternsStateCopyWith<$Res> {
  __$SavedPatternsStateCopyWithImpl(this._self, this._then);

  final _SavedPatternsState _self;
  final $Res Function(_SavedPatternsState) _then;

/// Create a copy of SavedPatternsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userPatterns = null,Object? starredPatterns = null,Object? publicPatterns = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_SavedPatternsState(
userPatterns: null == userPatterns ? _self._userPatterns : userPatterns // ignore: cast_nullable_to_non_nullable
as List<SavedPattern>,starredPatterns: null == starredPatterns ? _self._starredPatterns : starredPatterns // ignore: cast_nullable_to_non_nullable
as List<SavedPattern>,publicPatterns: null == publicPatterns ? _self._publicPatterns : publicPatterns // ignore: cast_nullable_to_non_nullable
as List<SavedPattern>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
