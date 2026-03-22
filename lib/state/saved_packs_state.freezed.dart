// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_packs_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavedPacksState {

 List<SavedPack> get userPacks; List<SavedPack> get publicPacks; bool get isLoading; String? get errorMessage;
/// Create a copy of SavedPacksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPacksStateCopyWith<SavedPacksState> get copyWith => _$SavedPacksStateCopyWithImpl<SavedPacksState>(this as SavedPacksState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPacksState&&const DeepCollectionEquality().equals(other.userPacks, userPacks)&&const DeepCollectionEquality().equals(other.publicPacks, publicPacks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userPacks),const DeepCollectionEquality().hash(publicPacks),isLoading,errorMessage);

@override
String toString() {
  return 'SavedPacksState(userPacks: $userPacks, publicPacks: $publicPacks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SavedPacksStateCopyWith<$Res>  {
  factory $SavedPacksStateCopyWith(SavedPacksState value, $Res Function(SavedPacksState) _then) = _$SavedPacksStateCopyWithImpl;
@useResult
$Res call({
 List<SavedPack> userPacks, List<SavedPack> publicPacks, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$SavedPacksStateCopyWithImpl<$Res>
    implements $SavedPacksStateCopyWith<$Res> {
  _$SavedPacksStateCopyWithImpl(this._self, this._then);

  final SavedPacksState _self;
  final $Res Function(SavedPacksState) _then;

/// Create a copy of SavedPacksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userPacks = null,Object? publicPacks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
userPacks: null == userPacks ? _self.userPacks : userPacks // ignore: cast_nullable_to_non_nullable
as List<SavedPack>,publicPacks: null == publicPacks ? _self.publicPacks : publicPacks // ignore: cast_nullable_to_non_nullable
as List<SavedPack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedPacksState].
extension SavedPacksStatePatterns on SavedPacksState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPacksState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPacksState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPacksState value)  $default,){
final _that = this;
switch (_that) {
case _SavedPacksState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPacksState value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPacksState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SavedPack> userPacks,  List<SavedPack> publicPacks,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPacksState() when $default != null:
return $default(_that.userPacks,_that.publicPacks,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SavedPack> userPacks,  List<SavedPack> publicPacks,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SavedPacksState():
return $default(_that.userPacks,_that.publicPacks,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SavedPack> userPacks,  List<SavedPack> publicPacks,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SavedPacksState() when $default != null:
return $default(_that.userPacks,_that.publicPacks,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SavedPacksState implements SavedPacksState {
  const _SavedPacksState({final  List<SavedPack> userPacks = const [], final  List<SavedPack> publicPacks = const [], this.isLoading = false, this.errorMessage}): _userPacks = userPacks,_publicPacks = publicPacks;
  

 final  List<SavedPack> _userPacks;
@override@JsonKey() List<SavedPack> get userPacks {
  if (_userPacks is EqualUnmodifiableListView) return _userPacks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userPacks);
}

 final  List<SavedPack> _publicPacks;
@override@JsonKey() List<SavedPack> get publicPacks {
  if (_publicPacks is EqualUnmodifiableListView) return _publicPacks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publicPacks);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of SavedPacksState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPacksStateCopyWith<_SavedPacksState> get copyWith => __$SavedPacksStateCopyWithImpl<_SavedPacksState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPacksState&&const DeepCollectionEquality().equals(other._userPacks, _userPacks)&&const DeepCollectionEquality().equals(other._publicPacks, _publicPacks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userPacks),const DeepCollectionEquality().hash(_publicPacks),isLoading,errorMessage);

@override
String toString() {
  return 'SavedPacksState(userPacks: $userPacks, publicPacks: $publicPacks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SavedPacksStateCopyWith<$Res> implements $SavedPacksStateCopyWith<$Res> {
  factory _$SavedPacksStateCopyWith(_SavedPacksState value, $Res Function(_SavedPacksState) _then) = __$SavedPacksStateCopyWithImpl;
@override @useResult
$Res call({
 List<SavedPack> userPacks, List<SavedPack> publicPacks, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$SavedPacksStateCopyWithImpl<$Res>
    implements _$SavedPacksStateCopyWith<$Res> {
  __$SavedPacksStateCopyWithImpl(this._self, this._then);

  final _SavedPacksState _self;
  final $Res Function(_SavedPacksState) _then;

/// Create a copy of SavedPacksState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userPacks = null,Object? publicPacks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_SavedPacksState(
userPacks: null == userPacks ? _self._userPacks : userPacks // ignore: cast_nullable_to_non_nullable
as List<SavedPack>,publicPacks: null == publicPacks ? _self._publicPacks : publicPacks // ignore: cast_nullable_to_non_nullable
as List<SavedPack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
