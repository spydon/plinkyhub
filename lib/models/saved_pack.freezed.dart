// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedPack {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt; String get description;@JsonKey(name: 'is_public') bool get isPublic;@JsonKey(name: 'pack_slots') List<PackSlot> get slots;
/// Create a copy of SavedPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPackCopyWith<SavedPack> get copyWith => _$SavedPackCopyWithImpl<SavedPack>(this as SavedPack, _$identity);

  /// Serializes this SavedPack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPack&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other.slots, slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,createdAt,updatedAt,description,isPublic,const DeepCollectionEquality().hash(slots));

@override
String toString() {
  return 'SavedPack(id: $id, userId: $userId, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, isPublic: $isPublic, slots: $slots)';
}


}

/// @nodoc
abstract mixin class $SavedPackCopyWith<$Res>  {
  factory $SavedPackCopyWith(SavedPack value, $Res Function(SavedPack) _then) = _$SavedPackCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, String description,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'pack_slots') List<PackSlot> slots
});




}
/// @nodoc
class _$SavedPackCopyWithImpl<$Res>
    implements $SavedPackCopyWith<$Res> {
  _$SavedPackCopyWithImpl(this._self, this._then);

  final SavedPack _self;
  final $Res Function(SavedPack) _then;

/// Create a copy of SavedPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? isPublic = null,Object? slots = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<PackSlot>,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedPack].
extension SavedPackPatterns on SavedPack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPack value)  $default,){
final _that = this;
switch (_that) {
case _SavedPack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPack value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  String description, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'pack_slots')  List<PackSlot> slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPack() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.createdAt,_that.updatedAt,_that.description,_that.isPublic,_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  String description, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'pack_slots')  List<PackSlot> slots)  $default,) {final _that = this;
switch (_that) {
case _SavedPack():
return $default(_that.id,_that.userId,_that.name,_that.createdAt,_that.updatedAt,_that.description,_that.isPublic,_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  String description, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'pack_slots')  List<PackSlot> slots)?  $default,) {final _that = this;
switch (_that) {
case _SavedPack() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.createdAt,_that.updatedAt,_that.description,_that.isPublic,_that.slots);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedPack implements SavedPack {
  const _SavedPack({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.description = '', @JsonKey(name: 'is_public') this.isPublic = false, @JsonKey(name: 'pack_slots') final  List<PackSlot> slots = const []}): _slots = slots;
  factory _SavedPack.fromJson(Map<String, dynamic> json) => _$SavedPackFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'is_public') final  bool isPublic;
 final  List<PackSlot> _slots;
@override@JsonKey(name: 'pack_slots') List<PackSlot> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}


/// Create a copy of SavedPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPackCopyWith<_SavedPack> get copyWith => __$SavedPackCopyWithImpl<_SavedPack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedPackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPack&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other._slots, _slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,createdAt,updatedAt,description,isPublic,const DeepCollectionEquality().hash(_slots));

@override
String toString() {
  return 'SavedPack(id: $id, userId: $userId, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, isPublic: $isPublic, slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$SavedPackCopyWith<$Res> implements $SavedPackCopyWith<$Res> {
  factory _$SavedPackCopyWith(_SavedPack value, $Res Function(_SavedPack) _then) = __$SavedPackCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, String description,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'pack_slots') List<PackSlot> slots
});




}
/// @nodoc
class __$SavedPackCopyWithImpl<$Res>
    implements _$SavedPackCopyWith<$Res> {
  __$SavedPackCopyWithImpl(this._self, this._then);

  final _SavedPack _self;
  final $Res Function(_SavedPack) _then;

/// Create a copy of SavedPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? isPublic = null,Object? slots = null,}) {
  return _then(_SavedPack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<PackSlot>,
  ));
}


}

// dart format on
