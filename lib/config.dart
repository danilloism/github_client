import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  const Env._();

  static String get githubClientId => _get('GITHUB_CLIENT_ID');
  static String get githubClientSecret => _get('GITHUB_CLIENT_SECRET');
  static List<String> get githubAuthScopes => ['repo', 'read:org'];
  static String get githubAuthUrl => 'https://github.com/login/oauth/authorize';
  static String get githubTokenUrl =>
      'https://github.com/login/oauth/access_token';
  static String get environment => _get('ENVIRONMENT');

  static String _get(String name) => dotenv.get(name);
}
