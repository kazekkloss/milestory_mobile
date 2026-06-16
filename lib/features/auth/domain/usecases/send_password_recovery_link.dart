import 'package:injectable/injectable.dart';
import 'package:milestory_mobile/core/error/response.dart';
import '../repository/auth_repository.dart';

@lazySingleton
class SendPasswordRecoveryLink {
  final AuthRepository repository;

  SendPasswordRecoveryLink(this.repository);

  Future<DataState> call({required String email}) async {
    return await repository.sendPasswordRecoveryLink(email: email);
  }
}
