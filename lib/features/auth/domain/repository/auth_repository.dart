import 'package:milestory_mobile/core/response/response.dart';
import '../../auth_export.dart';

abstract class AuthRepository {
  Future<DataState<User>> checkAuth();
}
