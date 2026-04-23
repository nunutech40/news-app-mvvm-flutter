class ApiConstants {
  /// Base URL Backend. Gunakan 10.0.2.2 untuk emulator Android lokal,
  /// atau IP server sungguhan.
  static const String baseUrl = 'http://103.181.143.73';

  // ===============================
  // AUTH ENTPOINT
  // ===============================
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String profile = '/api/v1/auth/me';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String health = '/health';

  // ===============================
  // NEWS ENDPOINT
  // ===============================
  static const String newsCategories = '/api/v1/news/categories';
  static const String newsFeed = '/api/v1/news';
  static const String newsDetail = '/api/v1/news';

  // ===============================
  // STORAGE KEYS
  // ===============================
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
