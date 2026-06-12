import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

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
    final response = await http.post(url, headers: _headers, body: jsonEncode(request.toJson()));

    if (response.statusCode == 200) {
      return UserResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      _handleError(response);
      throw Exception(); // Unreachable, but required by compiler
    }
  }

  // 유저 정보 수정
  static Future<UserResponse> updateUser(UserUpdateRequest request) async {
    final url = Uri.parse('$_baseUrl/users');
    final response = await http.patch(url, headers: _headers, body: jsonEncode(request.toJson()));

    if (response.statusCode == 200) {
      return UserResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      _handleError(response);
      throw Exception();
    }
  }

  // 점수 제출
  static Future<ScoreResponse> submitScore(ScoreSubmitRequest request) async {
    final url = Uri.parse('$_baseUrl/scores');
    final response = await http.post(url, headers: _headers, body: jsonEncode(request.toJson()));

    if (response.statusCode == 200) {
      return ScoreResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      _handleError(response);
      throw Exception();
    }
  }

  // 유저 점수 목록 조회
  static Future<List<ScoreResponse>> getUserScores(String teamName, String userName) async {
    final url = Uri.parse('$_baseUrl/scores/user').replace(
      queryParameters: {
        'teamName': teamName,
        'userName': userName,
      },
    );
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => ScoreResponse.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception();
    }
  }

  // 점수 삭제
  static Future<void> deleteScore(String teamName, String userName, int sector) async {
    final url = Uri.parse(_baseUrl).replace(
      pathSegments: [
        ...Uri.parse(_baseUrl).pathSegments,
        'scores',
        Uri.encodeComponent(teamName),
        Uri.encodeComponent(userName),
        sector.toString(),
      ],
    );
    final response = await http.delete(url, headers: _headers);

    if (response.statusCode != 204) {
      _handleError(response);
    }
  }

  // 랭킹 조회
  static Future<List<RankingResponse>> getRankings() async {
    final url = Uri.parse('$_baseUrl/rankings');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => RankingResponse.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception();
    }
  }
}
