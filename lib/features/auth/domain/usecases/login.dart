import 'package:injectable/injectable.dart';
import 'package:milestory_mobile/core/error/response.dart';
import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

@lazySingleton
class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<DataState<User>> call({required String email, required String password}) async {
    return await repository.login(email: email, password: password);
  }
}
