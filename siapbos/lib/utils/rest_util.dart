import 'package:siapbos/app_env.dart';

class RestUtil
{
  static final String _baseUrl = AppEnv().getApiDomain();
  String get baseUrl => _baseUrl;
}