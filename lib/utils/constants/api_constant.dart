import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
}
