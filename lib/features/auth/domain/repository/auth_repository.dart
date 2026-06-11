import 'package:milestory_mobile/core/response/response.dart';
import '../../auth_export.dart';

abstract class AuthRepository {
  Future<DataState<User>> checkAuth();
  Future<DataState<User>> login({
    required String email,
    required String password,
  });
  Future<DataState> logout({required bool isLocal});
  Future<DataState> register({required String email, required String password});
  Future<DataState> sendPasswordRecoveryLink({required String email});
  Future<DataState> deleteUser({required String userId});
}
