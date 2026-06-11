class ApiConstants {
  static const String baseUrl = 'http://192.168.1.11:3000/api';
  //static const String baseUrl = 'https://milestory.pl/api';

  static const String refreshToken = '$baseUrl/refresh-token';
  static const String platform = 'mobile';

  // AUTH
  static const String signUp = '$baseUrl/sign-up';
  static const String signIn = '$baseUrl/sign-in';
  static const String checkAuth = '$baseUrl/check-auth';
  static const String logout = '$baseUrl/logout';
  static const String sendPasswordRecoveryLink =
      '$baseUrl/send-link-password-recovery';
  static const String deleteUser = '$baseUrl/delete-user';
}
