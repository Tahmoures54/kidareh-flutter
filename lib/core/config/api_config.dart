class ApiConfig {
  ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'KIDAREH_API_URL',
    defaultValue: 'https://kidareh.com/api',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);
}
