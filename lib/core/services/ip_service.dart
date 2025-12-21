import 'dart:convert';
import 'package:http/http.dart' as http;

class IPService {
  static final IPService _instance = IPService._internal();
  factory IPService() => _instance;
  IPService._internal();

  String? _cachedIP;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get user's public IP address
  /// Returns null if unable to fetch
  Future<String?> getPublicIP() async {
    // Check cache first
    if (_cachedIP != null && _cacheTime != null) {
      final now = DateTime.now();
      if (now.difference(_cacheTime!) < _cacheDuration) {
        return _cachedIP;
      }
    }

    try {
      // Try multiple IP check services for reliability
      final services = [
        'https://api.ipify.org?format=json',
        'https://api64.ipify.org?format=json',
        'https://icanhazip.com',
      ];

      for (final service in services) {
        try {
          final response = await http.get(
            Uri.parse(service),
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            String ip;
            if (service.contains('ipify')) {
              final json = jsonDecode(response.body) as Map<String, dynamic>;
              ip = json['ip'] as String;
            } else {
              ip = response.body.trim();
            }

            // Validate IP format (basic check)
            if (_isValidIP(ip)) {
              _cachedIP = ip;
              _cacheTime = DateTime.now();
              return ip;
            }
          }
        } catch (e) {
          print('IP service failed: $service - $e');
          continue;
        }
      }

      return null;
    } catch (e) {
      print('Error getting public IP: $e');
      return null;
    }
  }

  /// Basic IP validation
  bool _isValidIP(String ip) {
    // IPv4 pattern
    final ipv4Regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    
    // IPv6 pattern (simplified)
    final ipv6Regex = RegExp(
      r'^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$',
    );

    return ipv4Regex.hasMatch(ip) || ipv6Regex.hasMatch(ip);
  }

  /// Clear cached IP
  void clearCache() {
    _cachedIP = null;
    _cacheTime = null;
  }
}

