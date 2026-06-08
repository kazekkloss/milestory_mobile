import 'package:injectable/injectable.dart';
import 'package:milestory_mobile/core/response/response.dart';
import '../../auth_export.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<DataState<User>> checkAuth() async {
    return await authDataSource.checkAuth();
  }
}
