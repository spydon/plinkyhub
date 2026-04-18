// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authentication_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthenticationState {

 bool get isLoading; User? get user; String? get username; String? get errorMessage; String? get infoMessage; String? get prefillEmail; bool get isPasswordRecovery;
/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationStateCopyWith<AuthenticationState> get copyWith => _$AuthenticationStateCopyWithImpl<AuthenticationState>(this as AuthenticationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.user, user) || other.user == user)&&(identical(other.username, username) || other.username == username)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&(identical(other.prefillEmail, prefillEmail) || other.prefillEmail == prefillEmail)&&(identical(other.isPasswordRecovery, isPasswordRecovery) || other.isPasswordRecovery == isPasswordRecovery));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,user,username,errorMessage,infoMessage,prefillEmail,isPasswordRecovery);

@override
String toString() {
  return 'AuthenticationState(isLoading: $isLoading, user: $user, username: $username, errorMessage: $errorMessage, infoMessage: $infoMessage, prefillEmail: $prefillEmail, isPasswordRecovery: $isPasswordRecovery)';
}


}

/// @nodoc
abstract mixin class $AuthenticationStateCopyWith<$Res>  {
  factory $AuthenticationStateCopyWith(AuthenticationState value, $Res Function(AuthenticationState) _then) = _$AuthenticationStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, User? user, String? username, String? errorMessage, String? infoMessage, String? prefillEmail, bool isPasswordRecovery
});




}
/// @nodoc
class _$AuthenticationStateCopyWithImpl<$Res>
    implements $AuthenticationStateCopyWith<$Res> {
  _$AuthenticationStateCopyWithImpl(this._self, this._then);

  final AuthenticationState _self;
  final $Res Function(AuthenticationState) _then;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? user = freezed,Object? username = freezed,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? prefillEmail = freezed,Object? isPasswordRecovery = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,prefillEmail: freezed == prefillEmail ? _self.prefillEmail : prefillEmail // ignore: cast_nullable_to_non_nullable
as String?,isPasswordRecovery: null == isPasswordRecovery ? _self.isPasswordRecovery : isPasswordRecovery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthenticationState].
extension AuthenticationStatePatterns on AuthenticationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthenticationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthenticationState value)  $default,){
final _that = this;
switch (_that) {
case _AuthenticationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthenticationState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  User? user,  String? username,  String? errorMessage,  String? infoMessage,  String? prefillEmail,  bool isPasswordRecovery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
return $default(_that.isLoading,_that.user,_that.username,_that.errorMessage,_that.infoMessage,_that.prefillEmail,_that.isPasswordRecovery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  User? user,  String? username,  String? errorMessage,  String? infoMessage,  String? prefillEmail,  bool isPasswordRecovery)  $default,) {final _that = this;
switch (_that) {
case _AuthenticationState():
return $default(_that.isLoading,_that.user,_that.username,_that.errorMessage,_that.infoMessage,_that.prefillEmail,_that.isPasswordRecovery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  User? user,  String? username,  String? errorMessage,  String? infoMessage,  String? prefillEmail,  bool isPasswordRecovery)?  $default,) {final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
return $default(_that.isLoading,_that.user,_that.username,_that.errorMessage,_that.infoMessage,_that.prefillEmail,_that.isPasswordRecovery);case _:
  return null;

}
}

}

/// @nodoc


class _AuthenticationState implements AuthenticationState {
  const _AuthenticationState({this.isLoading = false, this.user, this.username, this.errorMessage, this.infoMessage, this.prefillEmail, this.isPasswordRecovery = false});
  

@override@JsonKey() final  bool isLoading;
@override final  User? user;
@override final  String? username;
@override final  String? errorMessage;
@override final  String? infoMessage;
@override final  String? prefillEmail;
@override@JsonKey() final  bool isPasswordRecovery;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticationStateCopyWith<_AuthenticationState> get copyWith => __$AuthenticationStateCopyWithImpl<_AuthenticationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthenticationState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.user, user) || other.user == user)&&(identical(other.username, username) || other.username == username)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&(identical(other.prefillEmail, prefillEmail) || other.prefillEmail == prefillEmail)&&(identical(other.isPasswordRecovery, isPasswordRecovery) || other.isPasswordRecovery == isPasswordRecovery));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,user,username,errorMessage,infoMessage,prefillEmail,isPasswordRecovery);

@override
String toString() {
  return 'AuthenticationState(isLoading: $isLoading, user: $user, username: $username, errorMessage: $errorMessage, infoMessage: $infoMessage, prefillEmail: $prefillEmail, isPasswordRecovery: $isPasswordRecovery)';
}


}

/// @nodoc
abstract mixin class _$AuthenticationStateCopyWith<$Res> implements $AuthenticationStateCopyWith<$Res> {
  factory _$AuthenticationStateCopyWith(_AuthenticationState value, $Res Function(_AuthenticationState) _then) = __$AuthenticationStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, User? user, String? username, String? errorMessage, String? infoMessage, String? prefillEmail, bool isPasswordRecovery
});




}
/// @nodoc
class __$AuthenticationStateCopyWithImpl<$Res>
    implements _$AuthenticationStateCopyWith<$Res> {
  __$AuthenticationStateCopyWithImpl(this._self, this._then);

  final _AuthenticationState _self;
  final $Res Function(_AuthenticationState) _then;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? user = freezed,Object? username = freezed,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? prefillEmail = freezed,Object? isPasswordRecovery = null,}) {
  return _then(_AuthenticationState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,prefillEmail: freezed == prefillEmail ? _self.prefillEmail : prefillEmail // ignore: cast_nullable_to_non_nullable
as String?,isPasswordRecovery: null == isPasswordRecovery ? _self.isPasswordRecovery : isPasswordRecovery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
