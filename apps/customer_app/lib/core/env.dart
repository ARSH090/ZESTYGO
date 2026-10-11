/// Build-time environment: flutter run --dart-define=ENV=dev|staging|prod
abstract final class Env {
  static const String name = String.fromEnvironment('ENV', defaultValue: 'dev');
  static bool get isProd => name == 'prod';
}
