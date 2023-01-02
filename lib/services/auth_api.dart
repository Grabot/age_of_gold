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
          baseUrl: baseUrlV1_1,
          receiveTimeout: 15000,
          connectTimeout: 15000,
          sendTimeout: 15000,
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

    String? accessToken = await SecureStorage().getAccessToken();

    if (accessToken != null) {
      int current = (DateTime.now().millisecondsSinceEpoch/1000).round();
      Settings settings = Settings();
      int expiration = settings.getAccessTokenExpiration();

      if ((expiration - current) < 60) {

        String? refreshToken = settings.getRefreshToken();

        if (refreshToken == "") {

        } else {
          String endPoint = "refresh";
          var response = await Dio(
              BaseOptions(
                baseUrl: baseUrlV1_1,
                receiveTimeout: 15000,
                connectTimeout: 15000,
                sendTimeout: 15000,
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

          LoginResponse loginResponse = LoginResponse.fromJson(response.data);
          accessToken = loginResponse.getAccessToken();
          if (loginResponse.getResult()) {
            successfulLogin(null, loginResponse.getAccessToken(),
                loginResponse.getRefreshToken());
          } else {
            DioError dioError = DioError(requestOptions: options, type: DioErrorType.cancel, error: "User not authorized");
            return handler.reject(dioError, true);
          }
        }
      }

      options.headers['Authorization'] = 'Bearer: $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        throw DeadlineExceededException(err.requestOptions);
      case DioErrorType.response:
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
        break;
      case DioErrorType.other:
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