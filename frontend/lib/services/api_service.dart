import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_login_request.dart';
import '../models/user_response.dart';
import '../models/user_update_request.dart';
import '../models/score_submit_request.dart';
import '../models/score_response.dart';
import '../models/ranking_response.dart';
import '../models/error_response.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  static String get _baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }
    return 'http://localhost:8080/api';
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Future<T> _request<T>(
    Future<http.Response> Function() send, {
    required int successStatusCode,
    required T Function(dynamic decodedBody) parseBody,
  }) async {
    late final http.Response response;
    try {
      response = await send();
    } catch (_) {
      throw ApiException('서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.');
    }

    if (response.statusCode == successStatusCode) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      return parseBody(decodedBody);
    }

    _handleError(response);
    throw Exception('Unreachable');
  }

  static Future<List<T>> _requestList<T>(
    Future<http.Response> Function() send, {
    required int successStatusCode,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return _request(
      send,
      successStatusCode: successStatusCode,
      parseBody: (decodedBody) {
        final List<dynamic> data = decodedBody as List<dynamic>;
        return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  static Future<void> _requestVoid(
    Future<http.Response> Function() send, {
    required int successStatusCode,
  }) async {
    late final http.Response response;
    try {
      response = await send();
    } catch (_) {
      throw ApiException('서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.');
    }

    if (response.statusCode != successStatusCode) {
      _handleError(response);
    }
  }

  static void _handleError(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final errorResponse = ErrorResponse.fromJson(decoded);
      
      // 만약 field 에러 리스트가 있다면 가장 첫 번째 에러의 이유를 뽑아줌
      if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
         throw ApiException(
           errorResponse.errors!.first.reason,
           statusCode: response.statusCode,
         );
      }
      throw ApiException(
        errorResponse.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        '서버와 통신 중 오류가 발생했습니다. (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  // 로그인
  static Future<UserResponse> login(UserLoginRequest request) async {
    final url = Uri.parse('$_baseUrl/users/login');
    return _request(
      () => http.post(url, headers: _headers, body: jsonEncode(request.toJson())),
      successStatusCode: 200,
      parseBody: (decodedBody) => UserResponse.fromJson(decodedBody as Map<String, dynamic>),
    );
  }

  // 유저 정보 수정
  static Future<UserResponse> updateUser(int userId, UserUpdateRequest request) async {
    final url = Uri.parse('$_baseUrl/users/$userId');
    return _request(
      () => http.patch(url, headers: _headers, body: jsonEncode(request.toJson())),
      successStatusCode: 200,
      parseBody: (decodedBody) => UserResponse.fromJson(decodedBody as Map<String, dynamic>),
    );
  }

  // 점수 제출
  static Future<ScoreResponse> submitScore(ScoreSubmitRequest request) async {
    final url = Uri.parse('$_baseUrl/scores');
    return _request(
      () => http.post(url, headers: _headers, body: jsonEncode(request.toJson())),
      successStatusCode: 200,
      parseBody: (decodedBody) => ScoreResponse.fromJson(decodedBody as Map<String, dynamic>),
    );
  }

  // 유저 점수 목록 조회
  static Future<List<ScoreResponse>> getUserScores(int userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/scores');
    return _requestList(
      () => http.get(url, headers: _headers),
      successStatusCode: 200,
      fromJson: ScoreResponse.fromJson,
    );
  }

  // 점수 삭제
  static Future<void> deleteScore(int scoreId) async {
    final url = Uri.parse('$_baseUrl/scores/$scoreId');
    await _requestVoid(
      () => http.delete(url, headers: _headers),
      successStatusCode: 204,
    );
  }

  // 랭킹 조회
  static Future<List<RankingResponse>> getRankings() async {
    final url = Uri.parse('$_baseUrl/rankings');
    return _requestList(
      () => http.get(url, headers: _headers),
      successStatusCode: 200,
      fromJson: RankingResponse.fromJson,
    );
  }
}
