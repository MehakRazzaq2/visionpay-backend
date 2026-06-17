/// Central config for all backend URLs.
///
/// LAPTOP_IP — your laptop's WiFi IP (so physical phone can reach local services).
/// Run `ipconfig` on laptop → look for "IPv4 Address" under Wi-Fi.
/// Current value: 192.168.0.111
class AppConfig {
  static const String _laptopIp = '192.168.0.111';

  /// Main AI backend — hosted on Hugging Face Spaces.
  static const String apiBase =
      'https://mehakrazzaq2-visionpay-api.hf.space';

  /// Weight service — Python script running on laptop (port 8001).
  /// Uses LAN IP so both laptop browser AND physical phone can reach it
  /// as long as they are on the same WiFi network.
  static const String weightBase = 'http://$_laptopIp:8001';
}
