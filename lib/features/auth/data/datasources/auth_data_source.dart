import 'package:injectable/injectable.dart';

import '../../../../core/core_export.dart';
import '../../auth_export.dart';

abstract class AuthDataSource {
  Future<DataState<UserModel>> checkAuth();
}

@LazySingleton(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  final ApiClient apiClient;
  final TokenManager tokenManager;

  AuthDataSourceImpl(this.apiClient, this.tokenManager);

  @override
  Future<DataState<UserModel>> checkAuth() async {
    try {
      final token = tokenManager.accessToken;
      if (token == null || token.isEmpty) {
        return const DataFailed(UiEvent(message: 'Token is missing'));
      }

      final response = await apiClient.request(
        url: ApiConstants.checkAuth,
        method: RequestMethod.get,
      );

      if (response is DataSuccess) {
        final userModel = UserModel.fromJson(response.data);
        return DataSuccess(userModel);
      } else {
        return DataFailed(response.uiEvent!);
      }
    } catch (e) {
      return DataFailed(UiEvent(message: e.toString()));
    }
  }
}
