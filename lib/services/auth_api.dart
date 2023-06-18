import 'dart:io';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:dio/dio.dart';
import '../constants/url_base.dart';
import '../util/util.dart';
import 'models/login_response.dart';


class AuthApi {
  final dio = createDio();

  AuthApi._internal();

  static final _singleton = AuthApi._internal();

  factory AuthApi() => _singleton;

  static Dio createDio() {
    var dio = Dio(
        BaseOptions(
          baseUrl: apiUrlV1_0,
          receiveTimeout: const Duration(milliseconds: 15000),
          connectTimeout: const Duration(milliseconds: 15000),
          sendTimeout: const Duration(milliseconds: 15000),
        )
    );

    dio.interceptors.addAll({
      AppInterceptors(dio)
    });

    return dio;
  }
}

class AppInterceptors extends Interceptor {
  final Dio dio;

  AppInterceptors(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    Settings settings = Settings();
    int expiration = settings.getAccessTokenExpiration();
    if (expiration == 0) {
      // Just continue the request since it probably was a refresh
      return handler.next(options);
    } else {
      String? accessToken = await SecureStorage().getAccessToken();

      if (accessToken != null) {
        int current = (DateTime
            .now()
            .millisecondsSinceEpoch / 1000).round();

        if ((expiration - current) < 60) {
          // We see that the access token is almost expired. We should refresh it.
          String refreshToken = settings.getRefreshToken();

          if (refreshToken == "") {
            // We don't have a refresh token. We should log the user out.
            DioError dioError = DioError(requestOptions: options,
                type: DioErrorType.cancel,
                error: "User not authorized");
            return handler.reject(dioError, true);
          } else {
            settings.setLoggingIn(true);
            String endPoint = "refresh";
            var response = await Dio(
                BaseOptions(
                  baseUrl: apiUrlV1_0,
                  receiveTimeout: const Duration(milliseconds: 15000),
                  connectTimeout: const Duration(milliseconds: 15000),
                  sendTimeout: const Duration(milliseconds: 15000),
                )
            ).post(endPoint,
                options: Options(headers: {
                  HttpHeaders.contentTypeHeader: "application/json",
                }),
                data: {
                  "access_token": accessToken,
                  "refresh_token": refreshToken
                }
            ).catchError((error, stackTrace) {
              return handler.reject(error, true);
            });

            LoginResponse loginRefresh = LoginResponse.fromJson(response.data);
            if (loginRefresh.getResult()) {
              accessToken = loginRefresh.getAccessToken();
              successfulLogin(loginRefresh);
            } else {
              DioError dioError = DioError(requestOptions: options,
                  type: DioErrorType.cancel,
                  error: "User not authorized");
              return handler.reject(dioError, true);
            }
          }
        }

        options.headers['Authorization'] = 'Bearer: $accessToken';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print("on error! :(");
    switch (err.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        throw DeadlineExceededException(err.requestOptions);
      case DioErrorType.badResponse:
        if (err.response == null) {
          throw BadRequestException(err.requestOptions);
        }
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(err.requestOptions);
          case 401:
            throw UnauthorizedException(err.requestOptions);
          case 404:
            throw NotFoundException(err.requestOptions);
          case 409:
            throw ConflictException(err.requestOptions);
          case 500:
            throw InternalServerErrorException(err.requestOptions);
        }
        break;
      case DioErrorType.cancel:
        throw BadRequestException(err.requestOptions);
      case DioErrorType.unknown:
        throw NoInternetConnectionException(err.requestOptions);
      case DioErrorType.badCertificate:
        throw BadRequestException(err.requestOptions);
      case DioErrorType.connectionError:
        throw NoInternetConnectionException(err.requestOptions);
    }

    return handler.next(err);
  }
}

class BadRequestException extends DioError {
  BadRequestException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioError {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends DioError {
  ConflictException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class UnauthorizedException extends DioError {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioError {
  NotFoundException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends DioError {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class DeadlineExceededException extends DioError {
  DeadlineExceededException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}