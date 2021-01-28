import 'package:dio/dio.dart';
import 'package:flutter_api_rest/helper/http_response.dart';
import 'package:flutter_api_rest/utils/logs.dart';
import 'package:meta/meta.dart' show required;

class Http {
  Dio _dio;
  bool _logsEnabled;

  Http({
    @required Dio dio,
    @required bool logsEnabled,
  }) {
    _dio = dio;
    _logsEnabled = logsEnabled;
  }

  Future<HttpResponse<T>> request<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> data,
    Map<String, dynamic> formData,
    Map<String, dynamic> headers,
    T Function(dynamic data) parser,
  }) async {
    try {
      final Response response = await _dio.request(
        path,
        options: Options(
          headers: headers,
          method: method,
        ),
        queryParameters: queryParameters,
        data: formData != null ? FormData.fromMap(formData) : data,
      );
      Logs.instance.i(response.data);
      if (parser != null) {
        return HttpResponse.success<T>(parser(response.data));
      }
      return HttpResponse.success<T>(response.data);
    } catch (e) {
      Logs.instance.i(e);

      int statusCode = 0;
      String message = 'Error desconocido';
      dynamic data;

      if (e is DioError) {
        statusCode = -1;
        message = e.message;
        if (e.response != null) {
          statusCode = e.response.statusCode;
          message = e.response.statusMessage;
          data = e.response.data;
        }
      }
      return HttpResponse.fail(
        statusCode: statusCode,
        message: message,
        data: data,
      );
    }
  }
}
