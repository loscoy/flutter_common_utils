// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppApiResponse<T> {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AppApiResponse<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AppApiResponse<$T>()';
  }
}

/// @nodoc
class $AppApiResponseCopyWith<T, $Res> {
  $AppApiResponseCopyWith(
      AppApiResponse<T> _, $Res Function(AppApiResponse<T>) __);
}

/// Adds pattern-matching-related methods to [AppApiResponse].
extension AppApiResponsePatterns<T> on AppApiResponse<T> {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppApiResponseSuccess<T> value)? success,
    TResult Function(AppApiResponseError<T> value)? error,
    TResult Function(AppApiResponseNoUser<T> value)? noUser,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AppApiResponseSuccess() when success != null:
        return success(_that);
      case AppApiResponseError() when error != null:
        return error(_that);
      case AppApiResponseNoUser() when noUser != null:
        return noUser(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppApiResponseSuccess<T> value) success,
    required TResult Function(AppApiResponseError<T> value) error,
    required TResult Function(AppApiResponseNoUser<T> value) noUser,
  }) {
    final _that = this;
    switch (_that) {
      case AppApiResponseSuccess():
        return success(_that);
      case AppApiResponseError():
        return error(_that);
      case AppApiResponseNoUser():
        return noUser(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppApiResponseSuccess<T> value)? success,
    TResult? Function(AppApiResponseError<T> value)? error,
    TResult? Function(AppApiResponseNoUser<T> value)? noUser,
  }) {
    final _that = this;
    switch (_that) {
      case AppApiResponseSuccess() when success != null:
        return success(_that);
      case AppApiResponseError() when error != null:
        return error(_that);
      case AppApiResponseNoUser() when noUser != null:
        return noUser(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(String message)? error,
    TResult Function()? noUser,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AppApiResponseSuccess() when success != null:
        return success(_that.data);
      case AppApiResponseError() when error != null:
        return error(_that.message);
      case AppApiResponseNoUser() when noUser != null:
        return noUser();
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(String message) error,
    required TResult Function() noUser,
  }) {
    final _that = this;
    switch (_that) {
      case AppApiResponseSuccess():
        return success(_that.data);
      case AppApiResponseError():
        return error(_that.message);
      case AppApiResponseNoUser():
        return noUser();
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? success,
    TResult? Function(String message)? error,
    TResult? Function()? noUser,
  }) {
    final _that = this;
    switch (_that) {
      case AppApiResponseSuccess() when success != null:
        return success(_that.data);
      case AppApiResponseError() when error != null:
        return error(_that.message);
      case AppApiResponseNoUser() when noUser != null:
        return noUser();
      case _:
        return null;
    }
  }
}

/// @nodoc

class AppApiResponseSuccess<T> implements AppApiResponse<T> {
  const AppApiResponseSuccess(this.data);

  final T data;

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppApiResponseSuccessCopyWith<T, AppApiResponseSuccess<T>> get copyWith =>
      _$AppApiResponseSuccessCopyWithImpl<T, AppApiResponseSuccess<T>>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppApiResponseSuccess<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'AppApiResponse<$T>.success(data: $data)';
  }
}

/// @nodoc
abstract mixin class $AppApiResponseSuccessCopyWith<T, $Res>
    implements $AppApiResponseCopyWith<T, $Res> {
  factory $AppApiResponseSuccessCopyWith(AppApiResponseSuccess<T> value,
          $Res Function(AppApiResponseSuccess<T>) _then) =
      _$AppApiResponseSuccessCopyWithImpl;
  @useResult
  $Res call({T data});
}

/// @nodoc
class _$AppApiResponseSuccessCopyWithImpl<T, $Res>
    implements $AppApiResponseSuccessCopyWith<T, $Res> {
  _$AppApiResponseSuccessCopyWithImpl(this._self, this._then);

  final AppApiResponseSuccess<T> _self;
  final $Res Function(AppApiResponseSuccess<T>) _then;

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = freezed,
  }) {
    return _then(AppApiResponseSuccess<T>(
      freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class AppApiResponseError<T> implements AppApiResponse<T> {
  const AppApiResponseError(this.message);

  final String message;

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppApiResponseErrorCopyWith<T, AppApiResponseError<T>> get copyWith =>
      _$AppApiResponseErrorCopyWithImpl<T, AppApiResponseError<T>>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppApiResponseError<T> &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AppApiResponse<$T>.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $AppApiResponseErrorCopyWith<T, $Res>
    implements $AppApiResponseCopyWith<T, $Res> {
  factory $AppApiResponseErrorCopyWith(AppApiResponseError<T> value,
          $Res Function(AppApiResponseError<T>) _then) =
      _$AppApiResponseErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppApiResponseErrorCopyWithImpl<T, $Res>
    implements $AppApiResponseErrorCopyWith<T, $Res> {
  _$AppApiResponseErrorCopyWithImpl(this._self, this._then);

  final AppApiResponseError<T> _self;
  final $Res Function(AppApiResponseError<T>) _then;

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(AppApiResponseError<T>(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class AppApiResponseNoUser<T> implements AppApiResponse<T> {
  const AppApiResponseNoUser();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AppApiResponseNoUser<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AppApiResponse<$T>.noUser()';
  }
}

// dart format on
