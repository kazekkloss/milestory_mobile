import 'package:injectable/injectable.dart';
import '../../../../core/response/response.dart';
import '../repository/auth_repository.dart';

@lazySingleton
class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<DataState> call({required String email, required String password}) async {
    return await repository.register(email: email, password: password);
  }
}
