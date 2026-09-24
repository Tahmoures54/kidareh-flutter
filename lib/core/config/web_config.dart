import 'package:url_launcher/url_launcher.dart';

class WebConfig {
  WebConfig._();

  static const baseUrl = String.fromEnvironment(
    'KIDAREH_WEB_URL',
    defaultValue: 'https://kidareh.com',
  );

  static Uri page([String path = '/']) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }

  static Future<bool> open([String path = '/']) {
    return launchUrl(page(path), mode: LaunchMode.externalApplication);
  }
}
