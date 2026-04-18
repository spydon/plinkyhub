// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'highscores_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HighscoresState implements DiagnosticableTreeMixin {

 List<UserHighscore> get highscores; bool get isLoading; bool get hasLoaded; String? get errorMessage;
/// Create a copy of HighscoresState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HighscoresStateCopyWith<HighscoresState> get copyWith => _$HighscoresStateCopyWithImpl<HighscoresState>(this as HighscoresState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'HighscoresState'))
    ..add(DiagnosticsProperty('highscores', highscores))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('hasLoaded', hasLoaded))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HighscoresState&&const DeepCollectionEquality().equals(other.highscores, highscores)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasLoaded, hasLoaded) || other.hasLoaded == hasLoaded)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(highscores),isLoading,hasLoaded,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'HighscoresState(highscores: $highscores, isLoading: $isLoading, hasLoaded: $hasLoaded, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $HighscoresStateCopyWith<$Res>  {
  factory $HighscoresStateCopyWith(HighscoresState value, $Res Function(HighscoresState) _then) = _$HighscoresStateCopyWithImpl;
@useResult
$Res call({
 List<UserHighscore> highscores, bool isLoading, bool hasLoaded, String? errorMessage
});




}
/// @nodoc
class _$HighscoresStateCopyWithImpl<$Res>
    implements $HighscoresStateCopyWith<$Res> {
  _$HighscoresStateCopyWithImpl(this._self, this._then);

  final HighscoresState _self;
  final $Res Function(HighscoresState) _then;

/// Create a copy of HighscoresState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? highscores = null,Object? isLoading = null,Object? hasLoaded = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
highscores: null == highscores ? _self.highscores : highscores // ignore: cast_nullable_to_non_nullable
as List<UserHighscore>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasLoaded: null == hasLoaded ? _self.hasLoaded : hasLoaded // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HighscoresState].
extension HighscoresStatePatterns on HighscoresState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HighscoresState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HighscoresState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HighscoresState value)  $default,){
final _that = this;
switch (_that) {
case _HighscoresState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HighscoresState value)?  $default,){
final _that = this;
switch (_that) {
case _HighscoresState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UserHighscore> highscores,  bool isLoading,  bool hasLoaded,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HighscoresState() when $default != null:
return $default(_that.highscores,_that.isLoading,_that.hasLoaded,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UserHighscore> highscores,  bool isLoading,  bool hasLoaded,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _HighscoresState():
return $default(_that.highscores,_that.isLoading,_that.hasLoaded,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UserHighscore> highscores,  bool isLoading,  bool hasLoaded,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _HighscoresState() when $default != null:
return $default(_that.highscores,_that.isLoading,_that.hasLoaded,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _HighscoresState with DiagnosticableTreeMixin implements HighscoresState {
  const _HighscoresState({final  List<UserHighscore> highscores = const [], this.isLoading = false, this.hasLoaded = false, this.errorMessage}): _highscores = highscores;
  

 final  List<UserHighscore> _highscores;
@override@JsonKey() List<UserHighscore> get highscores {
  if (_highscores is EqualUnmodifiableListView) return _highscores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highscores);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool hasLoaded;
@override final  String? errorMessage;

/// Create a copy of HighscoresState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HighscoresStateCopyWith<_HighscoresState> get copyWith => __$HighscoresStateCopyWithImpl<_HighscoresState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'HighscoresState'))
    ..add(DiagnosticsProperty('highscores', highscores))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('hasLoaded', hasLoaded))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HighscoresState&&const DeepCollectionEquality().equals(other._highscores, _highscores)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasLoaded, hasLoaded) || other.hasLoaded == hasLoaded)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_highscores),isLoading,hasLoaded,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'HighscoresState(highscores: $highscores, isLoading: $isLoading, hasLoaded: $hasLoaded, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$HighscoresStateCopyWith<$Res> implements $HighscoresStateCopyWith<$Res> {
  factory _$HighscoresStateCopyWith(_HighscoresState value, $Res Function(_HighscoresState) _then) = __$HighscoresStateCopyWithImpl;
@override @useResult
$Res call({
 List<UserHighscore> highscores, bool isLoading, bool hasLoaded, String? errorMessage
});




}
/// @nodoc
class __$HighscoresStateCopyWithImpl<$Res>
    implements _$HighscoresStateCopyWith<$Res> {
  __$HighscoresStateCopyWithImpl(this._self, this._then);

  final _HighscoresState _self;
  final $Res Function(_HighscoresState) _then;

/// Create a copy of HighscoresState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? highscores = null,Object? isLoading = null,Object? hasLoaded = null,Object? errorMessage = freezed,}) {
  return _then(_HighscoresState(
highscores: null == highscores ? _self._highscores : highscores // ignore: cast_nullable_to_non_nullable
as List<UserHighscore>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasLoaded: null == hasLoaded ? _self.hasLoaded : hasLoaded // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserHighscore implements DiagnosticableTreeMixin {

 String get userId; String get username; int get totalStars; int get totalUploads;
/// Create a copy of UserHighscore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserHighscoreCopyWith<UserHighscore> get copyWith => _$UserHighscoreCopyWithImpl<UserHighscore>(this as UserHighscore, _$identity);

  /// Serializes this UserHighscore to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserHighscore'))
    ..add(DiagnosticsProperty('userId', userId))..add(DiagnosticsProperty('username', username))..add(DiagnosticsProperty('totalStars', totalStars))..add(DiagnosticsProperty('totalUploads', totalUploads));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserHighscore&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.totalStars, totalStars) || other.totalStars == totalStars)&&(identical(other.totalUploads, totalUploads) || other.totalUploads == totalUploads));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,totalStars,totalUploads);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserHighscore(userId: $userId, username: $username, totalStars: $totalStars, totalUploads: $totalUploads)';
}


}

/// @nodoc
abstract mixin class $UserHighscoreCopyWith<$Res>  {
  factory $UserHighscoreCopyWith(UserHighscore value, $Res Function(UserHighscore) _then) = _$UserHighscoreCopyWithImpl;
@useResult
$Res call({
 String userId, String username, int totalStars, int totalUploads
});




}
/// @nodoc
class _$UserHighscoreCopyWithImpl<$Res>
    implements $UserHighscoreCopyWith<$Res> {
  _$UserHighscoreCopyWithImpl(this._self, this._then);

  final UserHighscore _self;
  final $Res Function(UserHighscore) _then;

/// Create a copy of UserHighscore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? totalStars = null,Object? totalUploads = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,totalStars: null == totalStars ? _self.totalStars : totalStars // ignore: cast_nullable_to_non_nullable
as int,totalUploads: null == totalUploads ? _self.totalUploads : totalUploads // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserHighscore].
extension UserHighscorePatterns on UserHighscore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserHighscore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserHighscore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserHighscore value)  $default,){
final _that = this;
switch (_that) {
case _UserHighscore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserHighscore value)?  $default,){
final _that = this;
switch (_that) {
case _UserHighscore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  int totalStars,  int totalUploads)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserHighscore() when $default != null:
return $default(_that.userId,_that.username,_that.totalStars,_that.totalUploads);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  int totalStars,  int totalUploads)  $default,) {final _that = this;
switch (_that) {
case _UserHighscore():
return $default(_that.userId,_that.username,_that.totalStars,_that.totalUploads);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  int totalStars,  int totalUploads)?  $default,) {final _that = this;
switch (_that) {
case _UserHighscore() when $default != null:
return $default(_that.userId,_that.username,_that.totalStars,_that.totalUploads);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserHighscore with DiagnosticableTreeMixin implements UserHighscore {
  const _UserHighscore({required this.userId, required this.username, required this.totalStars, required this.totalUploads});
  factory _UserHighscore.fromJson(Map<String, dynamic> json) => _$UserHighscoreFromJson(json);

@override final  String userId;
@override final  String username;
@override final  int totalStars;
@override final  int totalUploads;

/// Create a copy of UserHighscore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserHighscoreCopyWith<_UserHighscore> get copyWith => __$UserHighscoreCopyWithImpl<_UserHighscore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserHighscoreToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserHighscore'))
    ..add(DiagnosticsProperty('userId', userId))..add(DiagnosticsProperty('username', username))..add(DiagnosticsProperty('totalStars', totalStars))..add(DiagnosticsProperty('totalUploads', totalUploads));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserHighscore&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.totalStars, totalStars) || other.totalStars == totalStars)&&(identical(other.totalUploads, totalUploads) || other.totalUploads == totalUploads));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,totalStars,totalUploads);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserHighscore(userId: $userId, username: $username, totalStars: $totalStars, totalUploads: $totalUploads)';
}


}

/// @nodoc
abstract mixin class _$UserHighscoreCopyWith<$Res> implements $UserHighscoreCopyWith<$Res> {
  factory _$UserHighscoreCopyWith(_UserHighscore value, $Res Function(_UserHighscore) _then) = __$UserHighscoreCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, int totalStars, int totalUploads
});




}
/// @nodoc
class __$UserHighscoreCopyWithImpl<$Res>
    implements _$UserHighscoreCopyWith<$Res> {
  __$UserHighscoreCopyWithImpl(this._self, this._then);

  final _UserHighscore _self;
  final $Res Function(_UserHighscore) _then;

/// Create a copy of UserHighscore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? totalStars = null,Object? totalUploads = null,}) {
  return _then(_UserHighscore(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,totalStars: null == totalStars ? _self.totalStars : totalStars // ignore: cast_nullable_to_non_nullable
as int,totalUploads: null == totalUploads ? _self.totalUploads : totalUploads // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
