class ApiEndpoints {
  static const String baseUrl =
      'http://44.213.72.167:5000/api'; // AWS EC2 Instance

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Logs
  static String getDailyLog(String date) => '/logs/$date';

  // Water
  static const String updateWater = '/water/update';

  // Food / AI
  static const String analyzeFood = '/food/analyze';
  static const String confirmFood = '/food/confirm';
}
