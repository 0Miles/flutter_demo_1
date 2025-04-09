import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/clock_info.dart';

class ClockService {
  static const String _baseUrl = 'https://api.nueip.site';
  final String token;

  ClockService({required this.token});

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<ClockInfo> fetchClockInfo() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/hrm/clock/info'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        return ClockInfo.fromJson(data['data']);
      } else {
        throw Exception('API Error: ${data['message']}');
      }
    } else {
      throw Exception('Network Error: ${response.statusCode}');
    }
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
           '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> clockIn() async {
    final position = await _getCurrentPosition();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/hrm/clock/in'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'time': _getCurrentDateTime(),
        'lat': position?.latitude.toString() ?? 'undefined',
        'lng': position?.longitude.toString() ?? 'undefined',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] != 200) {
        throw Exception('API Error: ${data['message']}');
      }
    } else {
      throw Exception('Network Error: ${response.statusCode}');
    }
  }

  Future<void> clockOut() async {
    final position = await _getCurrentPosition();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/hrm/clock/out'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'time': _getCurrentDateTime(),
        'lat': position?.latitude.toString() ?? 'undefined',
        'lng': position?.longitude.toString() ?? 'undefined',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] != 200) {
        throw Exception('API Error: ${data['message']}');
      }
    } else {
      throw Exception('Network Error: ${response.statusCode}');
    }
  }
}