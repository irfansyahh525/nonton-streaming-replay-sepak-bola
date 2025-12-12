import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streaming_bola_app/models/match.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const Duration timeout = Duration(seconds: 10);

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: headers,
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Get All Matches
  Future<List<Match>> getMatches(
      {String? status, bool? isReplay, String? search}) async {
    try {
      String url = '$baseUrl/matches?';

      if (status != null) {
        url += 'status=$status&';
      }

      if (isReplay != null) {
        url += 'is_replay=${isReplay ? 1 : 0}&';
      }

      if (search != null && search.isNotEmpty) {
        url += 'search=$search&';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List matches = data['matches'];
          return matches.map((match) => Match.fromJson(match)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting matches: $e');
      return [];
    }
  }

  // Get Live Matches
  Future<List<Match>> getLiveMatches() async {
    return getMatches(status: 'live');
  }

  // Get Replay Matches
  Future<List<Match>> getReplayMatches() async {
    return getMatches(isReplay: true);
  }

  // Search Matches
  Future<List<Match>> searchMatches(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/matches/search?q=$query'),
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List matches = data['matches'];
          return matches.map((match) => Match.fromJson(match)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching matches: $e');
      return [];
    }
  }

  // Add to History
  Future<bool> addToHistory(int userId, int matchId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/history'),
            headers: headers,
            body: jsonEncode({
              'user_id': userId,
              'match_id': matchId,
            }),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error adding to history: $e');
      return false;
    }
  }
}
