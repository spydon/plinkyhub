// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackUploadRequest {

 PackUploadPack get packData; List<PackUploadSample> get samplesData; List<PackUploadPreset> get presetsData; PackUploadWavetable? get wavetableData; List<PackUploadPattern> get patternsData; List<PackUploadSlot> get packSlotsData;
/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackUploadRequestCopyWith<PackUploadRequest> get copyWith => _$PackUploadRequestCopyWithImpl<PackUploadRequest>(this as PackUploadRequest, _$identity);

  /// Serializes this PackUploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackUploadRequest&&(identical(other.packData, packData) || other.packData == packData)&&const DeepCollectionEquality().equals(other.samplesData, samplesData)&&const DeepCollectionEquality().equals(other.presetsData, presetsData)&&(identical(other.wavetableData, wavetableData) || other.wavetableData == wavetableData)&&const DeepCollectionEquality().equals(other.patternsData, patternsData)&&const DeepCollectionEquality().equals(other.packSlotsData, packSlotsData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packData,const DeepCollectionEquality().hash(samplesData),const DeepCollectionEquality().hash(presetsData),wavetableData,const DeepCollectionEquality().hash(patternsData),const DeepCollectionEquality().hash(packSlotsData));

@override
String toString() {
  return 'PackUploadRequest(packData: $packData, samplesData: $samplesData, presetsData: $presetsData, wavetableData: $wavetableData, patternsData: $patternsData, packSlotsData: $packSlotsData)';
}


}

/// @nodoc
abstract mixin class $PackUploadRequestCopyWith<$Res>  {
  factory $PackUploadRequestCopyWith(PackUploadRequest value, $Res Function(PackUploadRequest) _then) = _$PackUploadRequestCopyWithImpl;
@useResult
$Res call({
 PackUploadPack packData, List<PackUploadSample> samplesData, List<PackUploadPreset> presetsData, PackUploadWavetable? wavetableData, List<PackUploadPattern> patternsData, List<PackUploadSlot> packSlotsData
});


$PackUploadPackCopyWith<$Res> get packData;$PackUploadWavetableCopyWith<$Res>? get wavetableData;

}
/// @nodoc
class _$PackUploadRequestCopyWithImpl<$Res>
    implements $PackUploadRequestCopyWith<$Res> {
  _$PackUploadRequestCopyWithImpl(this._self, this._then);

  final PackUploadRequest _self;
  final $Res Function(PackUploadRequest) _then;

/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packData = null,Object? samplesData = null,Object? presetsData = null,Object? wavetableData = freezed,Object? patternsData = null,Object? packSlotsData = null,}) {
  return _then(_self.copyWith(
packData: null == packData ? _self.packData : packData // ignore: cast_nullable_to_non_nullable
as PackUploadPack,samplesData: null == samplesData ? _self.samplesData : samplesData // ignore: cast_nullable_to_non_nullable
as List<PackUploadSample>,presetsData: null == presetsData ? _self.presetsData : presetsData // ignore: cast_nullable_to_non_nullable
as List<PackUploadPreset>,wavetableData: freezed == wavetableData ? _self.wavetableData : wavetableData // ignore: cast_nullable_to_non_nullable
as PackUploadWavetable?,patternsData: null == patternsData ? _self.patternsData : patternsData // ignore: cast_nullable_to_non_nullable
as List<PackUploadPattern>,packSlotsData: null == packSlotsData ? _self.packSlotsData : packSlotsData // ignore: cast_nullable_to_non_nullable
as List<PackUploadSlot>,
  ));
}
/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackUploadPackCopyWith<$Res> get packData {
  
  return $PackUploadPackCopyWith<$Res>(_self.packData, (value) {
    return _then(_self.copyWith(packData: value));
  });
}/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackUploadWavetableCopyWith<$Res>? get wavetableData {
    if (_self.wavetableData == null) {
    return null;
  }

  return $PackUploadWavetableCopyWith<$Res>(_self.wavetableData!, (value) {
    return _then(_self.copyWith(wavetableData: value));
  });
}
}


/// Adds pattern-matching-related methods to [PackUploadRequest].
extension PackUploadRequestPatterns on PackUploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackUploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackUploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackUploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _PackUploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackUploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PackUploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PackUploadPack packData,  List<PackUploadSample> samplesData,  List<PackUploadPreset> presetsData,  PackUploadWavetable? wavetableData,  List<PackUploadPattern> patternsData,  List<PackUploadSlot> packSlotsData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackUploadRequest() when $default != null:
return $default(_that.packData,_that.samplesData,_that.presetsData,_that.wavetableData,_that.patternsData,_that.packSlotsData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PackUploadPack packData,  List<PackUploadSample> samplesData,  List<PackUploadPreset> presetsData,  PackUploadWavetable? wavetableData,  List<PackUploadPattern> patternsData,  List<PackUploadSlot> packSlotsData)  $default,) {final _that = this;
switch (_that) {
case _PackUploadRequest():
return $default(_that.packData,_that.samplesData,_that.presetsData,_that.wavetableData,_that.patternsData,_that.packSlotsData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PackUploadPack packData,  List<PackUploadSample> samplesData,  List<PackUploadPreset> presetsData,  PackUploadWavetable? wavetableData,  List<PackUploadPattern> patternsData,  List<PackUploadSlot> packSlotsData)?  $default,) {final _that = this;
switch (_that) {
case _PackUploadRequest() when $default != null:
return $default(_that.packData,_that.samplesData,_that.presetsData,_that.wavetableData,_that.patternsData,_that.packSlotsData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackUploadRequest implements PackUploadRequest {
  const _PackUploadRequest({required this.packData, final  List<PackUploadSample> samplesData = const [], final  List<PackUploadPreset> presetsData = const [], this.wavetableData, final  List<PackUploadPattern> patternsData = const [], final  List<PackUploadSlot> packSlotsData = const []}): _samplesData = samplesData,_presetsData = presetsData,_patternsData = patternsData,_packSlotsData = packSlotsData;
  factory _PackUploadRequest.fromJson(Map<String, dynamic> json) => _$PackUploadRequestFromJson(json);

@override final  PackUploadPack packData;
 final  List<PackUploadSample> _samplesData;
@override@JsonKey() List<PackUploadSample> get samplesData {
  if (_samplesData is EqualUnmodifiableListView) return _samplesData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_samplesData);
}

 final  List<PackUploadPreset> _presetsData;
@override@JsonKey() List<PackUploadPreset> get presetsData {
  if (_presetsData is EqualUnmodifiableListView) return _presetsData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_presetsData);
}

@override final  PackUploadWavetable? wavetableData;
 final  List<PackUploadPattern> _patternsData;
@override@JsonKey() List<PackUploadPattern> get patternsData {
  if (_patternsData is EqualUnmodifiableListView) return _patternsData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_patternsData);
}

 final  List<PackUploadSlot> _packSlotsData;
@override@JsonKey() List<PackUploadSlot> get packSlotsData {
  if (_packSlotsData is EqualUnmodifiableListView) return _packSlotsData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packSlotsData);
}


/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackUploadRequestCopyWith<_PackUploadRequest> get copyWith => __$PackUploadRequestCopyWithImpl<_PackUploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackUploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackUploadRequest&&(identical(other.packData, packData) || other.packData == packData)&&const DeepCollectionEquality().equals(other._samplesData, _samplesData)&&const DeepCollectionEquality().equals(other._presetsData, _presetsData)&&(identical(other.wavetableData, wavetableData) || other.wavetableData == wavetableData)&&const DeepCollectionEquality().equals(other._patternsData, _patternsData)&&const DeepCollectionEquality().equals(other._packSlotsData, _packSlotsData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packData,const DeepCollectionEquality().hash(_samplesData),const DeepCollectionEquality().hash(_presetsData),wavetableData,const DeepCollectionEquality().hash(_patternsData),const DeepCollectionEquality().hash(_packSlotsData));

@override
String toString() {
  return 'PackUploadRequest(packData: $packData, samplesData: $samplesData, presetsData: $presetsData, wavetableData: $wavetableData, patternsData: $patternsData, packSlotsData: $packSlotsData)';
}


}

/// @nodoc
abstract mixin class _$PackUploadRequestCopyWith<$Res> implements $PackUploadRequestCopyWith<$Res> {
  factory _$PackUploadRequestCopyWith(_PackUploadRequest value, $Res Function(_PackUploadRequest) _then) = __$PackUploadRequestCopyWithImpl;
@override @useResult
$Res call({
 PackUploadPack packData, List<PackUploadSample> samplesData, List<PackUploadPreset> presetsData, PackUploadWavetable? wavetableData, List<PackUploadPattern> patternsData, List<PackUploadSlot> packSlotsData
});


@override $PackUploadPackCopyWith<$Res> get packData;@override $PackUploadWavetableCopyWith<$Res>? get wavetableData;

}
/// @nodoc
class __$PackUploadRequestCopyWithImpl<$Res>
    implements _$PackUploadRequestCopyWith<$Res> {
  __$PackUploadRequestCopyWithImpl(this._self, this._then);

  final _PackUploadRequest _self;
  final $Res Function(_PackUploadRequest) _then;

/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packData = null,Object? samplesData = null,Object? presetsData = null,Object? wavetableData = freezed,Object? patternsData = null,Object? packSlotsData = null,}) {
  return _then(_PackUploadRequest(
packData: null == packData ? _self.packData : packData // ignore: cast_nullable_to_non_nullable
as PackUploadPack,samplesData: null == samplesData ? _self._samplesData : samplesData // ignore: cast_nullable_to_non_nullable
as List<PackUploadSample>,presetsData: null == presetsData ? _self._presetsData : presetsData // ignore: cast_nullable_to_non_nullable
as List<PackUploadPreset>,wavetableData: freezed == wavetableData ? _self.wavetableData : wavetableData // ignore: cast_nullable_to_non_nullable
as PackUploadWavetable?,patternsData: null == patternsData ? _self._patternsData : patternsData // ignore: cast_nullable_to_non_nullable
as List<PackUploadPattern>,packSlotsData: null == packSlotsData ? _self._packSlotsData : packSlotsData // ignore: cast_nullable_to_non_nullable
as List<PackUploadSlot>,
  ));
}

/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackUploadPackCopyWith<$Res> get packData {
  
  return $PackUploadPackCopyWith<$Res>(_self.packData, (value) {
    return _then(_self.copyWith(packData: value));
  });
}/// Create a copy of PackUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackUploadWavetableCopyWith<$Res>? get wavetableData {
    if (_self.wavetableData == null) {
    return null;
  }

  return $PackUploadWavetableCopyWith<$Res>(_self.wavetableData!, (value) {
    return _then(_self.copyWith(wavetableData: value));
  });
}
}


/// @nodoc
mixin _$PackUploadPack {

 String get userId; String get name; String get description; bool get isPublic; String get youtubeUrl; String? get contentHash;
/// Create a copy of PackUploadPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackUploadPackCopyWith<PackUploadPack> get copyWith => _$PackUploadPackCopyWithImpl<PackUploadPack>(this as PackUploadPack, _$identity);

  /// Serializes this PackUploadPack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackUploadPack&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,description,isPublic,youtubeUrl,contentHash);

@override
String toString() {
  return 'PackUploadPack(userId: $userId, name: $name, description: $description, isPublic: $isPublic, youtubeUrl: $youtubeUrl, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class $PackUploadPackCopyWith<$Res>  {
  factory $PackUploadPackCopyWith(PackUploadPack value, $Res Function(PackUploadPack) _then) = _$PackUploadPackCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String description, bool isPublic, String youtubeUrl, String? contentHash
});




}
/// @nodoc
class _$PackUploadPackCopyWithImpl<$Res>
    implements $PackUploadPackCopyWith<$Res> {
  _$PackUploadPackCopyWithImpl(this._self, this._then);

  final PackUploadPack _self;
  final $Res Function(PackUploadPack) _then;

/// Create a copy of PackUploadPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? description = null,Object? isPublic = null,Object? youtubeUrl = null,Object? contentHash = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackUploadPack].
extension PackUploadPackPatterns on PackUploadPack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackUploadPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackUploadPack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackUploadPack value)  $default,){
final _that = this;
switch (_that) {
case _PackUploadPack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackUploadPack value)?  $default,){
final _that = this;
switch (_that) {
case _PackUploadPack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String description,  bool isPublic,  String youtubeUrl,  String? contentHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackUploadPack() when $default != null:
return $default(_that.userId,_that.name,_that.description,_that.isPublic,_that.youtubeUrl,_that.contentHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String description,  bool isPublic,  String youtubeUrl,  String? contentHash)  $default,) {final _that = this;
switch (_that) {
case _PackUploadPack():
return $default(_that.userId,_that.name,_that.description,_that.isPublic,_that.youtubeUrl,_that.contentHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String description,  bool isPublic,  String youtubeUrl,  String? contentHash)?  $default,) {final _that = this;
switch (_that) {
case _PackUploadPack() when $default != null:
return $default(_that.userId,_that.name,_that.description,_that.isPublic,_that.youtubeUrl,_that.contentHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackUploadPack implements PackUploadPack {
  const _PackUploadPack({required this.userId, required this.name, this.description = '', this.isPublic = false, this.youtubeUrl = '', this.contentHash});
  factory _PackUploadPack.fromJson(Map<String, dynamic> json) => _$PackUploadPackFromJson(json);

@override final  String userId;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  String youtubeUrl;
@override final  String? contentHash;

/// Create a copy of PackUploadPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackUploadPackCopyWith<_PackUploadPack> get copyWith => __$PackUploadPackCopyWithImpl<_PackUploadPack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackUploadPackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackUploadPack&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,description,isPublic,youtubeUrl,contentHash);

@override
String toString() {
  return 'PackUploadPack(userId: $userId, name: $name, description: $description, isPublic: $isPublic, youtubeUrl: $youtubeUrl, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class _$PackUploadPackCopyWith<$Res> implements $PackUploadPackCopyWith<$Res> {
  factory _$PackUploadPackCopyWith(_PackUploadPack value, $Res Function(_PackUploadPack) _then) = __$PackUploadPackCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String description, bool isPublic, String youtubeUrl, String? contentHash
});




}
/// @nodoc
class __$PackUploadPackCopyWithImpl<$Res>
    implements _$PackUploadPackCopyWith<$Res> {
  __$PackUploadPackCopyWithImpl(this._self, this._then);

  final _PackUploadPack _self;
  final $Res Function(_PackUploadPack) _then;

/// Create a copy of PackUploadPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? description = null,Object? isPublic = null,Object? youtubeUrl = null,Object? contentHash = freezed,}) {
  return _then(_PackUploadPack(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PackUploadSample {

 int get slotIndex; String get userId; String get name; String get filePath; String get pcmFilePath; String get description; bool get isPublic; List<double> get slicePoints; int get baseNote; int get fineTune; bool get pitched; List<int> get sliceNotes; String? get contentHash; String? get existingId;
/// Create a copy of PackUploadSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackUploadSampleCopyWith<PackUploadSample> get copyWith => _$PackUploadSampleCopyWithImpl<PackUploadSample>(this as PackUploadSample, _$identity);

  /// Serializes this PackUploadSample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackUploadSample&&(identical(other.slotIndex, slotIndex) || other.slotIndex == slotIndex)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.pcmFilePath, pcmFilePath) || other.pcmFilePath == pcmFilePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other.slicePoints, slicePoints)&&(identical(other.baseNote, baseNote) || other.baseNote == baseNote)&&(identical(other.fineTune, fineTune) || other.fineTune == fineTune)&&(identical(other.pitched, pitched) || other.pitched == pitched)&&const DeepCollectionEquality().equals(other.sliceNotes, sliceNotes)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotIndex,userId,name,filePath,pcmFilePath,description,isPublic,const DeepCollectionEquality().hash(slicePoints),baseNote,fineTune,pitched,const DeepCollectionEquality().hash(sliceNotes),contentHash,existingId);

@override
String toString() {
  return 'PackUploadSample(slotIndex: $slotIndex, userId: $userId, name: $name, filePath: $filePath, pcmFilePath: $pcmFilePath, description: $description, isPublic: $isPublic, slicePoints: $slicePoints, baseNote: $baseNote, fineTune: $fineTune, pitched: $pitched, sliceNotes: $sliceNotes, contentHash: $contentHash, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class $PackUploadSampleCopyWith<$Res>  {
  factory $PackUploadSampleCopyWith(PackUploadSample value, $Res Function(PackUploadSample) _then) = _$PackUploadSampleCopyWithImpl;
@useResult
$Res call({
 int slotIndex, String userId, String name, String filePath, String pcmFilePath, String description, bool isPublic, List<double> slicePoints, int baseNote, int fineTune, bool pitched, List<int> sliceNotes, String? contentHash, String? existingId
});




}
/// @nodoc
class _$PackUploadSampleCopyWithImpl<$Res>
    implements $PackUploadSampleCopyWith<$Res> {
  _$PackUploadSampleCopyWithImpl(this._self, this._then);

  final PackUploadSample _self;
  final $Res Function(PackUploadSample) _then;

/// Create a copy of PackUploadSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slotIndex = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? pcmFilePath = null,Object? description = null,Object? isPublic = null,Object? slicePoints = null,Object? baseNote = null,Object? fineTune = null,Object? pitched = null,Object? sliceNotes = null,Object? contentHash = freezed,Object? existingId = freezed,}) {
  return _then(_self.copyWith(
slotIndex: null == slotIndex ? _self.slotIndex : slotIndex // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
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
as List<int>,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackUploadSample].
extension PackUploadSamplePatterns on PackUploadSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackUploadSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackUploadSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackUploadSample value)  $default,){
final _that = this;
switch (_that) {
case _PackUploadSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackUploadSample value)?  $default,){
final _that = this;
switch (_that) {
case _PackUploadSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int slotIndex,  String userId,  String name,  String filePath,  String pcmFilePath,  String description,  bool isPublic,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes,  String? contentHash,  String? existingId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackUploadSample() when $default != null:
return $default(_that.slotIndex,_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.description,_that.isPublic,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes,_that.contentHash,_that.existingId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int slotIndex,  String userId,  String name,  String filePath,  String pcmFilePath,  String description,  bool isPublic,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes,  String? contentHash,  String? existingId)  $default,) {final _that = this;
switch (_that) {
case _PackUploadSample():
return $default(_that.slotIndex,_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.description,_that.isPublic,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes,_that.contentHash,_that.existingId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int slotIndex,  String userId,  String name,  String filePath,  String pcmFilePath,  String description,  bool isPublic,  List<double> slicePoints,  int baseNote,  int fineTune,  bool pitched,  List<int> sliceNotes,  String? contentHash,  String? existingId)?  $default,) {final _that = this;
switch (_that) {
case _PackUploadSample() when $default != null:
return $default(_that.slotIndex,_that.userId,_that.name,_that.filePath,_that.pcmFilePath,_that.description,_that.isPublic,_that.slicePoints,_that.baseNote,_that.fineTune,_that.pitched,_that.sliceNotes,_that.contentHash,_that.existingId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackUploadSample implements PackUploadSample {
  const _PackUploadSample({required this.slotIndex, required this.userId, required this.name, required this.filePath, required this.pcmFilePath, this.description = '', this.isPublic = false, final  List<double> slicePoints = const [], this.baseNote = 60, this.fineTune = 0, this.pitched = false, final  List<int> sliceNotes = const [], this.contentHash, this.existingId}): _slicePoints = slicePoints,_sliceNotes = sliceNotes;
  factory _PackUploadSample.fromJson(Map<String, dynamic> json) => _$PackUploadSampleFromJson(json);

@override final  int slotIndex;
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

@override final  String? contentHash;
@override final  String? existingId;

/// Create a copy of PackUploadSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackUploadSampleCopyWith<_PackUploadSample> get copyWith => __$PackUploadSampleCopyWithImpl<_PackUploadSample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackUploadSampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackUploadSample&&(identical(other.slotIndex, slotIndex) || other.slotIndex == slotIndex)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.pcmFilePath, pcmFilePath) || other.pcmFilePath == pcmFilePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other._slicePoints, _slicePoints)&&(identical(other.baseNote, baseNote) || other.baseNote == baseNote)&&(identical(other.fineTune, fineTune) || other.fineTune == fineTune)&&(identical(other.pitched, pitched) || other.pitched == pitched)&&const DeepCollectionEquality().equals(other._sliceNotes, _sliceNotes)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotIndex,userId,name,filePath,pcmFilePath,description,isPublic,const DeepCollectionEquality().hash(_slicePoints),baseNote,fineTune,pitched,const DeepCollectionEquality().hash(_sliceNotes),contentHash,existingId);

@override
String toString() {
  return 'PackUploadSample(slotIndex: $slotIndex, userId: $userId, name: $name, filePath: $filePath, pcmFilePath: $pcmFilePath, description: $description, isPublic: $isPublic, slicePoints: $slicePoints, baseNote: $baseNote, fineTune: $fineTune, pitched: $pitched, sliceNotes: $sliceNotes, contentHash: $contentHash, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class _$PackUploadSampleCopyWith<$Res> implements $PackUploadSampleCopyWith<$Res> {
  factory _$PackUploadSampleCopyWith(_PackUploadSample value, $Res Function(_PackUploadSample) _then) = __$PackUploadSampleCopyWithImpl;
@override @useResult
$Res call({
 int slotIndex, String userId, String name, String filePath, String pcmFilePath, String description, bool isPublic, List<double> slicePoints, int baseNote, int fineTune, bool pitched, List<int> sliceNotes, String? contentHash, String? existingId
});




}
/// @nodoc
class __$PackUploadSampleCopyWithImpl<$Res>
    implements _$PackUploadSampleCopyWith<$Res> {
  __$PackUploadSampleCopyWithImpl(this._self, this._then);

  final _PackUploadSample _self;
  final $Res Function(_PackUploadSample) _then;

/// Create a copy of PackUploadSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slotIndex = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? pcmFilePath = null,Object? description = null,Object? isPublic = null,Object? slicePoints = null,Object? baseNote = null,Object? fineTune = null,Object? pitched = null,Object? sliceNotes = null,Object? contentHash = freezed,Object? existingId = freezed,}) {
  return _then(_PackUploadSample(
slotIndex: null == slotIndex ? _self.slotIndex : slotIndex // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
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
as List<int>,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PackUploadPreset {

 int get slotIndex; String get userId; String get name; String get category; String get presetData; String get description; bool get isPublic; String? get contentHash; String? get existingId; int? get sampleSlotIndex;
/// Create a copy of PackUploadPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackUploadPresetCopyWith<PackUploadPreset> get copyWith => _$PackUploadPresetCopyWithImpl<PackUploadPreset>(this as PackUploadPreset, _$identity);

  /// Serializes this PackUploadPreset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackUploadPreset&&(identical(other.slotIndex, slotIndex) || other.slotIndex == slotIndex)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.presetData, presetData) || other.presetData == presetData)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId)&&(identical(other.sampleSlotIndex, sampleSlotIndex) || other.sampleSlotIndex == sampleSlotIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotIndex,userId,name,category,presetData,description,isPublic,contentHash,existingId,sampleSlotIndex);

@override
String toString() {
  return 'PackUploadPreset(slotIndex: $slotIndex, userId: $userId, name: $name, category: $category, presetData: $presetData, description: $description, isPublic: $isPublic, contentHash: $contentHash, existingId: $existingId, sampleSlotIndex: $sampleSlotIndex)';
}


}

/// @nodoc
abstract mixin class $PackUploadPresetCopyWith<$Res>  {
  factory $PackUploadPresetCopyWith(PackUploadPreset value, $Res Function(PackUploadPreset) _then) = _$PackUploadPresetCopyWithImpl;
@useResult
$Res call({
 int slotIndex, String userId, String name, String category, String presetData, String description, bool isPublic, String? contentHash, String? existingId, int? sampleSlotIndex
});




}
/// @nodoc
class _$PackUploadPresetCopyWithImpl<$Res>
    implements $PackUploadPresetCopyWith<$Res> {
  _$PackUploadPresetCopyWithImpl(this._self, this._then);

  final PackUploadPreset _self;
  final $Res Function(PackUploadPreset) _then;

/// Create a copy of PackUploadPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slotIndex = null,Object? userId = null,Object? name = null,Object? category = null,Object? presetData = null,Object? description = null,Object? isPublic = null,Object? contentHash = freezed,Object? existingId = freezed,Object? sampleSlotIndex = freezed,}) {
  return _then(_self.copyWith(
slotIndex: null == slotIndex ? _self.slotIndex : slotIndex // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,presetData: null == presetData ? _self.presetData : presetData // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,sampleSlotIndex: freezed == sampleSlotIndex ? _self.sampleSlotIndex : sampleSlotIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackUploadPreset].
extension PackUploadPresetPatterns on PackUploadPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackUploadPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackUploadPreset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackUploadPreset value)  $default,){
final _that = this;
switch (_that) {
case _PackUploadPreset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackUploadPreset value)?  $default,){
final _that = this;
switch (_that) {
case _PackUploadPreset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int slotIndex,  String userId,  String name,  String category,  String presetData,  String description,  bool isPublic,  String? contentHash,  String? existingId,  int? sampleSlotIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackUploadPreset() when $default != null:
return $default(_that.slotIndex,_that.userId,_that.name,_that.category,_that.presetData,_that.description,_that.isPublic,_that.contentHash,_that.existingId,_that.sampleSlotIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int slotIndex,  String userId,  String name,  String category,  String presetData,  String description,  bool isPublic,  String? contentHash,  String? existingId,  int? sampleSlotIndex)  $default,) {final _that = this;
switch (_that) {
case _PackUploadPreset():
return $default(_that.slotIndex,_that.userId,_that.name,_that.category,_that.presetData,_that.description,_that.isPublic,_that.contentHash,_that.existingId,_that.sampleSlotIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int slotIndex,  String userId,  String name,  String category,  String presetData,  String description,  bool isPublic,  String? contentHash,  String? existingId,  int? sampleSlotIndex)?  $default,) {final _that = this;
switch (_that) {
case _PackUploadPreset() when $default != null:
return $default(_that.slotIndex,_that.userId,_that.name,_that.category,_that.presetData,_that.description,_that.isPublic,_that.contentHash,_that.existingId,_that.sampleSlotIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackUploadPreset implements PackUploadPreset {
  const _PackUploadPreset({required this.slotIndex, required this.userId, required this.name, required this.category, required this.presetData, this.description = '', this.isPublic = false, this.contentHash, this.existingId, this.sampleSlotIndex});
  factory _PackUploadPreset.fromJson(Map<String, dynamic> json) => _$PackUploadPresetFromJson(json);

@override final  int slotIndex;
@override final  String userId;
@override final  String name;
@override final  String category;
@override final  String presetData;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override final  String? contentHash;
@override final  String? existingId;
@override final  int? sampleSlotIndex;

/// Create a copy of PackUploadPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackUploadPresetCopyWith<_PackUploadPreset> get copyWith => __$PackUploadPresetCopyWithImpl<_PackUploadPreset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackUploadPresetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackUploadPreset&&(identical(other.slotIndex, slotIndex) || other.slotIndex == slotIndex)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.presetData, presetData) || other.presetData == presetData)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId)&&(identical(other.sampleSlotIndex, sampleSlotIndex) || other.sampleSlotIndex == sampleSlotIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotIndex,userId,name,category,presetData,description,isPublic,contentHash,existingId,sampleSlotIndex);

@override
String toString() {
  return 'PackUploadPreset(slotIndex: $slotIndex, userId: $userId, name: $name, category: $category, presetData: $presetData, description: $description, isPublic: $isPublic, contentHash: $contentHash, existingId: $existingId, sampleSlotIndex: $sampleSlotIndex)';
}


}

/// @nodoc
abstract mixin class _$PackUploadPresetCopyWith<$Res> implements $PackUploadPresetCopyWith<$Res> {
  factory _$PackUploadPresetCopyWith(_PackUploadPreset value, $Res Function(_PackUploadPreset) _then) = __$PackUploadPresetCopyWithImpl;
@override @useResult
$Res call({
 int slotIndex, String userId, String name, String category, String presetData, String description, bool isPublic, String? contentHash, String? existingId, int? sampleSlotIndex
});




}
/// @nodoc
class __$PackUploadPresetCopyWithImpl<$Res>
    implements _$PackUploadPresetCopyWith<$Res> {
  __$PackUploadPresetCopyWithImpl(this._self, this._then);

  final _PackUploadPreset _self;
  final $Res Function(_PackUploadPreset) _then;

/// Create a copy of PackUploadPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slotIndex = null,Object? userId = null,Object? name = null,Object? category = null,Object? presetData = null,Object? description = null,Object? isPublic = null,Object? contentHash = freezed,Object? existingId = freezed,Object? sampleSlotIndex = freezed,}) {
  return _then(_PackUploadPreset(
slotIndex: null == slotIndex ? _self.slotIndex : slotIndex // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,presetData: null == presetData ? _self.presetData : presetData // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,sampleSlotIndex: freezed == sampleSlotIndex ? _self.sampleSlotIndex : sampleSlotIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$PackUploadWavetable {

 String get userId; String get name; String get filePath; String get description; bool get isPublic; String? get contentHash; String? get existingId;
/// Create a copy of PackUploadWavetable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackUploadWavetableCopyWith<PackUploadWavetable> get copyWith => _$PackUploadWavetableCopyWithImpl<PackUploadWavetable>(this as PackUploadWavetable, _$identity);

  /// Serializes this PackUploadWavetable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackUploadWavetable&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,filePath,description,isPublic,contentHash,existingId);

@override
String toString() {
  return 'PackUploadWavetable(userId: $userId, name: $name, filePath: $filePath, description: $description, isPublic: $isPublic, contentHash: $contentHash, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class $PackUploadWavetableCopyWith<$Res>  {
  factory $PackUploadWavetableCopyWith(PackUploadWavetable value, $Res Function(PackUploadWavetable) _then) = _$PackUploadWavetableCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String filePath, String description, bool isPublic, String? contentHash, String? existingId
});




}
/// @nodoc
class _$PackUploadWavetableCopyWithImpl<$Res>
    implements $PackUploadWavetableCopyWith<$Res> {
  _$PackUploadWavetableCopyWithImpl(this._self, this._then);

  final PackUploadWavetable _self;
  final $Res Function(PackUploadWavetable) _then;

/// Create a copy of PackUploadWavetable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? filePath = null,Object? description = null,Object? isPublic = null,Object? contentHash = freezed,Object? existingId = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackUploadWavetable].
extension PackUploadWavetablePatterns on PackUploadWavetable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackUploadWavetable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackUploadWavetable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackUploadWavetable value)  $default,){
final _that = this;
switch (_that) {
case _PackUploadWavetable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackUploadWavetable value)?  $default,){
final _that = this;
switch (_that) {
case _PackUploadWavetable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String filePath,  String description,  bool isPublic,  String? contentHash,  String? existingId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackUploadWavetable() when $default != null:
return $default(_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.contentHash,_that.existingId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String filePath,  String description,  bool isPublic,  String? contentHash,  String? existingId)  $default,) {final _that = this;
switch (_that) {
case _PackUploadWavetable():
return $default(_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.contentHash,_that.existingId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String filePath,  String description,  bool isPublic,  String? contentHash,  String? existingId)?  $default,) {final _that = this;
switch (_that) {
case _PackUploadWavetable() when $default != null:
return $default(_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.contentHash,_that.existingId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackUploadWavetable implements PackUploadWavetable {
  const _PackUploadWavetable({required this.userId, required this.name, required this.filePath, this.description = '', this.isPublic = false, this.contentHash, this.existingId});
  factory _PackUploadWavetable.fromJson(Map<String, dynamic> json) => _$PackUploadWavetableFromJson(json);

@override final  String userId;
@override final  String name;
@override final  String filePath;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override final  String? contentHash;
@override final  String? existingId;

/// Create a copy of PackUploadWavetable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackUploadWavetableCopyWith<_PackUploadWavetable> get copyWith => __$PackUploadWavetableCopyWithImpl<_PackUploadWavetable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackUploadWavetableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackUploadWavetable&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,filePath,description,isPublic,contentHash,existingId);

@override
String toString() {
  return 'PackUploadWavetable(userId: $userId, name: $name, filePath: $filePath, description: $description, isPublic: $isPublic, contentHash: $contentHash, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class _$PackUploadWavetableCopyWith<$Res> implements $PackUploadWavetableCopyWith<$Res> {
  factory _$PackUploadWavetableCopyWith(_PackUploadWavetable value, $Res Function(_PackUploadWavetable) _then) = __$PackUploadWavetableCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String filePath, String description, bool isPublic, String? contentHash, String? existingId
});




}
/// @nodoc
class __$PackUploadWavetableCopyWithImpl<$Res>
    implements _$PackUploadWavetableCopyWith<$Res> {
  __$PackUploadWavetableCopyWithImpl(this._self, this._then);

  final _PackUploadWavetable _self;
  final $Res Function(_PackUploadWavetable) _then;

/// Create a copy of PackUploadWavetable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? filePath = null,Object? description = null,Object? isPublic = null,Object? contentHash = freezed,Object? existingId = freezed,}) {
  return _then(_PackUploadWavetable(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PackUploadPattern {

 int get patternIndex; String get userId; String get name; String get filePath; String get description; bool get isPublic; String? get contentHash; String? get existingId;
/// Create a copy of PackUploadPattern
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackUploadPatternCopyWith<PackUploadPattern> get copyWith => _$PackUploadPatternCopyWithImpl<PackUploadPattern>(this as PackUploadPattern, _$identity);

  /// Serializes this PackUploadPattern to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackUploadPattern&&(identical(other.patternIndex, patternIndex) || other.patternIndex == patternIndex)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patternIndex,userId,name,filePath,description,isPublic,contentHash,existingId);

@override
String toString() {
  return 'PackUploadPattern(patternIndex: $patternIndex, userId: $userId, name: $name, filePath: $filePath, description: $description, isPublic: $isPublic, contentHash: $contentHash, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class $PackUploadPatternCopyWith<$Res>  {
  factory $PackUploadPatternCopyWith(PackUploadPattern value, $Res Function(PackUploadPattern) _then) = _$PackUploadPatternCopyWithImpl;
@useResult
$Res call({
 int patternIndex, String userId, String name, String filePath, String description, bool isPublic, String? contentHash, String? existingId
});




}
/// @nodoc
class _$PackUploadPatternCopyWithImpl<$Res>
    implements $PackUploadPatternCopyWith<$Res> {
  _$PackUploadPatternCopyWithImpl(this._self, this._then);

  final PackUploadPattern _self;
  final $Res Function(PackUploadPattern) _then;

/// Create a copy of PackUploadPattern
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patternIndex = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? description = null,Object? isPublic = null,Object? contentHash = freezed,Object? existingId = freezed,}) {
  return _then(_self.copyWith(
patternIndex: null == patternIndex ? _self.patternIndex : patternIndex // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackUploadPattern].
extension PackUploadPatternPatterns on PackUploadPattern {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackUploadPattern value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackUploadPattern() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackUploadPattern value)  $default,){
final _that = this;
switch (_that) {
case _PackUploadPattern():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackUploadPattern value)?  $default,){
final _that = this;
switch (_that) {
case _PackUploadPattern() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int patternIndex,  String userId,  String name,  String filePath,  String description,  bool isPublic,  String? contentHash,  String? existingId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackUploadPattern() when $default != null:
return $default(_that.patternIndex,_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.contentHash,_that.existingId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int patternIndex,  String userId,  String name,  String filePath,  String description,  bool isPublic,  String? contentHash,  String? existingId)  $default,) {final _that = this;
switch (_that) {
case _PackUploadPattern():
return $default(_that.patternIndex,_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.contentHash,_that.existingId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int patternIndex,  String userId,  String name,  String filePath,  String description,  bool isPublic,  String? contentHash,  String? existingId)?  $default,) {final _that = this;
switch (_that) {
case _PackUploadPattern() when $default != null:
return $default(_that.patternIndex,_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.contentHash,_that.existingId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackUploadPattern implements PackUploadPattern {
  const _PackUploadPattern({required this.patternIndex, required this.userId, required this.name, required this.filePath, this.description = '', this.isPublic = false, this.contentHash, this.existingId});
  factory _PackUploadPattern.fromJson(Map<String, dynamic> json) => _$PackUploadPatternFromJson(json);

@override final  int patternIndex;
@override final  String userId;
@override final  String name;
@override final  String filePath;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override final  String? contentHash;
@override final  String? existingId;

/// Create a copy of PackUploadPattern
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackUploadPatternCopyWith<_PackUploadPattern> get copyWith => __$PackUploadPatternCopyWithImpl<_PackUploadPattern>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackUploadPatternToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackUploadPattern&&(identical(other.patternIndex, patternIndex) || other.patternIndex == patternIndex)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.existingId, existingId) || other.existingId == existingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patternIndex,userId,name,filePath,description,isPublic,contentHash,existingId);

@override
String toString() {
  return 'PackUploadPattern(patternIndex: $patternIndex, userId: $userId, name: $name, filePath: $filePath, description: $description, isPublic: $isPublic, contentHash: $contentHash, existingId: $existingId)';
}


}

/// @nodoc
abstract mixin class _$PackUploadPatternCopyWith<$Res> implements $PackUploadPatternCopyWith<$Res> {
  factory _$PackUploadPatternCopyWith(_PackUploadPattern value, $Res Function(_PackUploadPattern) _then) = __$PackUploadPatternCopyWithImpl;
@override @useResult
$Res call({
 int patternIndex, String userId, String name, String filePath, String description, bool isPublic, String? contentHash, String? existingId
});




}
/// @nodoc
class __$PackUploadPatternCopyWithImpl<$Res>
    implements _$PackUploadPatternCopyWith<$Res> {
  __$PackUploadPatternCopyWithImpl(this._self, this._then);

  final _PackUploadPattern _self;
  final $Res Function(_PackUploadPattern) _then;

/// Create a copy of PackUploadPattern
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patternIndex = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? description = null,Object? isPublic = null,Object? contentHash = freezed,Object? existingId = freezed,}) {
  return _then(_PackUploadPattern(
patternIndex: null == patternIndex ? _self.patternIndex : patternIndex // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,existingId: freezed == existingId ? _self.existingId : existingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PackUploadSlot {

 int get slotNumber; int? get presetSlotIndex; int? get sampleSlotIndex; int? get patternIndex;
/// Create a copy of PackUploadSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackUploadSlotCopyWith<PackUploadSlot> get copyWith => _$PackUploadSlotCopyWithImpl<PackUploadSlot>(this as PackUploadSlot, _$identity);

  /// Serializes this PackUploadSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackUploadSlot&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.presetSlotIndex, presetSlotIndex) || other.presetSlotIndex == presetSlotIndex)&&(identical(other.sampleSlotIndex, sampleSlotIndex) || other.sampleSlotIndex == sampleSlotIndex)&&(identical(other.patternIndex, patternIndex) || other.patternIndex == patternIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotNumber,presetSlotIndex,sampleSlotIndex,patternIndex);

@override
String toString() {
  return 'PackUploadSlot(slotNumber: $slotNumber, presetSlotIndex: $presetSlotIndex, sampleSlotIndex: $sampleSlotIndex, patternIndex: $patternIndex)';
}


}

/// @nodoc
abstract mixin class $PackUploadSlotCopyWith<$Res>  {
  factory $PackUploadSlotCopyWith(PackUploadSlot value, $Res Function(PackUploadSlot) _then) = _$PackUploadSlotCopyWithImpl;
@useResult
$Res call({
 int slotNumber, int? presetSlotIndex, int? sampleSlotIndex, int? patternIndex
});




}
/// @nodoc
class _$PackUploadSlotCopyWithImpl<$Res>
    implements $PackUploadSlotCopyWith<$Res> {
  _$PackUploadSlotCopyWithImpl(this._self, this._then);

  final PackUploadSlot _self;
  final $Res Function(PackUploadSlot) _then;

/// Create a copy of PackUploadSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slotNumber = null,Object? presetSlotIndex = freezed,Object? sampleSlotIndex = freezed,Object? patternIndex = freezed,}) {
  return _then(_self.copyWith(
slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,presetSlotIndex: freezed == presetSlotIndex ? _self.presetSlotIndex : presetSlotIndex // ignore: cast_nullable_to_non_nullable
as int?,sampleSlotIndex: freezed == sampleSlotIndex ? _self.sampleSlotIndex : sampleSlotIndex // ignore: cast_nullable_to_non_nullable
as int?,patternIndex: freezed == patternIndex ? _self.patternIndex : patternIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackUploadSlot].
extension PackUploadSlotPatterns on PackUploadSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackUploadSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackUploadSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackUploadSlot value)  $default,){
final _that = this;
switch (_that) {
case _PackUploadSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackUploadSlot value)?  $default,){
final _that = this;
switch (_that) {
case _PackUploadSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int slotNumber,  int? presetSlotIndex,  int? sampleSlotIndex,  int? patternIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackUploadSlot() when $default != null:
return $default(_that.slotNumber,_that.presetSlotIndex,_that.sampleSlotIndex,_that.patternIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int slotNumber,  int? presetSlotIndex,  int? sampleSlotIndex,  int? patternIndex)  $default,) {final _that = this;
switch (_that) {
case _PackUploadSlot():
return $default(_that.slotNumber,_that.presetSlotIndex,_that.sampleSlotIndex,_that.patternIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int slotNumber,  int? presetSlotIndex,  int? sampleSlotIndex,  int? patternIndex)?  $default,) {final _that = this;
switch (_that) {
case _PackUploadSlot() when $default != null:
return $default(_that.slotNumber,_that.presetSlotIndex,_that.sampleSlotIndex,_that.patternIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackUploadSlot implements PackUploadSlot {
  const _PackUploadSlot({required this.slotNumber, this.presetSlotIndex, this.sampleSlotIndex, this.patternIndex});
  factory _PackUploadSlot.fromJson(Map<String, dynamic> json) => _$PackUploadSlotFromJson(json);

@override final  int slotNumber;
@override final  int? presetSlotIndex;
@override final  int? sampleSlotIndex;
@override final  int? patternIndex;

/// Create a copy of PackUploadSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackUploadSlotCopyWith<_PackUploadSlot> get copyWith => __$PackUploadSlotCopyWithImpl<_PackUploadSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackUploadSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackUploadSlot&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.presetSlotIndex, presetSlotIndex) || other.presetSlotIndex == presetSlotIndex)&&(identical(other.sampleSlotIndex, sampleSlotIndex) || other.sampleSlotIndex == sampleSlotIndex)&&(identical(other.patternIndex, patternIndex) || other.patternIndex == patternIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotNumber,presetSlotIndex,sampleSlotIndex,patternIndex);

@override
String toString() {
  return 'PackUploadSlot(slotNumber: $slotNumber, presetSlotIndex: $presetSlotIndex, sampleSlotIndex: $sampleSlotIndex, patternIndex: $patternIndex)';
}


}

/// @nodoc
abstract mixin class _$PackUploadSlotCopyWith<$Res> implements $PackUploadSlotCopyWith<$Res> {
  factory _$PackUploadSlotCopyWith(_PackUploadSlot value, $Res Function(_PackUploadSlot) _then) = __$PackUploadSlotCopyWithImpl;
@override @useResult
$Res call({
 int slotNumber, int? presetSlotIndex, int? sampleSlotIndex, int? patternIndex
});




}
/// @nodoc
class __$PackUploadSlotCopyWithImpl<$Res>
    implements _$PackUploadSlotCopyWith<$Res> {
  __$PackUploadSlotCopyWithImpl(this._self, this._then);

  final _PackUploadSlot _self;
  final $Res Function(_PackUploadSlot) _then;

/// Create a copy of PackUploadSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slotNumber = null,Object? presetSlotIndex = freezed,Object? sampleSlotIndex = freezed,Object? patternIndex = freezed,}) {
  return _then(_PackUploadSlot(
slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,presetSlotIndex: freezed == presetSlotIndex ? _self.presetSlotIndex : presetSlotIndex // ignore: cast_nullable_to_non_nullable
as int?,sampleSlotIndex: freezed == sampleSlotIndex ? _self.sampleSlotIndex : sampleSlotIndex // ignore: cast_nullable_to_non_nullable
as int?,patternIndex: freezed == patternIndex ? _self.patternIndex : patternIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
