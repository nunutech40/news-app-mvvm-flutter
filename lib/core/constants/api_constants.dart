class ApiConstants {
  /// Base URL Backend. Gunakan 10.0.2.2 untuk emulator Android lokal,
  /// atau IP server sungguhan.
  static const String baseUrl = 'http://103.181.143.73:8081/api/v1';

  // ===============================
  // AUTH ENTPOINT
  // ===============================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String health = '/health';

  // ===============================
  // NEWS ENDPOINT
  // ===============================
  static const String newsCategories = '/news/categories';
  static const String newsFeed = '/news/feed';
  static const String newsDetail = '/news/article';

  // ===============================
  // STORAGE KEYS
  // ===============================
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
