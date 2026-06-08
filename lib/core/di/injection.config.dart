// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:milestory_mobile/core/core_export.dart' as _i455;
import 'package:milestory_mobile/core/di/injection.dart' as _i259;
import 'package:milestory_mobile/core/network/api_client.dart' as _i620;
import 'package:milestory_mobile/core/services/token/token_manager.dart'
    as _i54;
import 'package:milestory_mobile/features/auth/auth_export.dart' as _i983;
import 'package:milestory_mobile/features/auth/data/datasources/auth_data_source.dart'
    as _i404;
import 'package:milestory_mobile/features/auth/data/repository/auth_repository_impl.dart'
    as _i24;
import 'package:milestory_mobile/features/auth/domain/repository/auth_repository.dart'
    as _i681;
import 'package:milestory_mobile/features/auth/domain/usecases/check_auth.dart'
    as _i430;
import 'package:milestory_mobile/features/auth/presentation/bloc/auth_bloc.dart'
    as _i291;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i54.TokenManager>(
      () => _i54.TokenManager(gh<_i361.Dio>(), gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i620.ApiClient>(
      () => _i620.ApiClient(gh<_i361.Dio>(), gh<_i455.TokenManager>()),
    );
    gh.lazySingleton<_i404.AuthDataSource>(
      () => _i404.AuthDataSourceImpl(
        gh<_i455.ApiClient>(),
        gh<_i455.TokenManager>(),
      ),
    );
    gh.lazySingleton<_i983.AuthRepository>(
      () => _i24.AuthRepositoryImpl(authDataSource: gh<_i983.AuthDataSource>()),
    );
    gh.lazySingleton<_i430.CheckAuth>(
      () => _i430.CheckAuth(gh<_i681.AuthRepository>()),
    );
    gh.factory<_i291.AuthBloc>(
      () => _i291.AuthBloc(checkAuth: gh<_i983.CheckAuth>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i259.RegisterModule {}
