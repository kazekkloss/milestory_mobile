// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:milestory_mobile/core/core_export.dart' as _i455;
import 'package:milestory_mobile/core/di/injection.dart' as _i259;
import 'package:milestory_mobile/core/network/api_client.dart' as _i620;
import 'package:milestory_mobile/core/services/token_manager.dart' as _i234;
import 'package:milestory_mobile/features/auth/auth_export.dart' as _i983;
import 'package:milestory_mobile/features/auth/data/datasources/auth_data_source.dart'
    as _i404;
import 'package:milestory_mobile/features/auth/data/repository/auth_repository_impl.dart'
    as _i24;
import 'package:milestory_mobile/features/auth/domain/repository/auth_repository.dart'
    as _i681;
import 'package:milestory_mobile/features/auth/domain/usecases/check_auth.dart'
    as _i430;
import 'package:milestory_mobile/features/auth/domain/usecases/delete_user.dart'
    as _i211;
import 'package:milestory_mobile/features/auth/domain/usecases/login.dart'
    as _i812;
import 'package:milestory_mobile/features/auth/domain/usecases/logout.dart'
    as _i308;
import 'package:milestory_mobile/features/auth/domain/usecases/registration.dart'
    as _i321;
import 'package:milestory_mobile/features/auth/domain/usecases/send_password_recovery_link.dart'
    as _i1050;
import 'package:milestory_mobile/features/auth/presentation/bloc/auth_bloc.dart'
    as _i291;
import 'package:milestory_mobile/features/map/data/datasources/map_data_source.dart'
    as _i718;
import 'package:milestory_mobile/features/map/data/repository/map_repository_impl.dart'
    as _i943;
import 'package:milestory_mobile/features/map/data/repository/tour_tracking_repository_impl.dart'
    as _i249;
import 'package:milestory_mobile/features/map/data/services/tour_tracking_service.dart'
    as _i99;
import 'package:milestory_mobile/features/map/domain/repository/tour_tracking_repository.dart'
    as _i438;
import 'package:milestory_mobile/features/map/domain/usecases/get_tour_points.dart'
    as _i86;
import 'package:milestory_mobile/features/map/domain/usecases/set_tour_points.dart'
    as _i130;
import 'package:milestory_mobile/features/map/map_export.dart' as _i864;
import 'package:milestory_mobile/features/map/presentation/bloc/map_bloc.dart'
    as _i125;
import 'package:milestory_mobile/features/tour/data/datasources/tour_data_source.dart'
    as _i193;
import 'package:milestory_mobile/features/tour/data/repository/tour_repository_impl.dart'
    as _i810;
import 'package:milestory_mobile/features/tour/domain/usecases/search_tour.dart'
    as _i380;
import 'package:milestory_mobile/features/tour/presentation/tour_bloc/tour_bloc.dart'
    as _i879;
import 'package:milestory_mobile/features/tour/tour_export.dart' as _i870;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i99.TourTrackingService>(
      () => _i99.TourTrackingService(),
    );
    gh.lazySingleton<_i438.TourTrackingRepository>(
      () => _i249.TourTrackingRepositoryImpl(gh<_i99.TourTrackingService>()),
    );
    await gh.factoryAsync<_i234.TokenManager>(
      () => registerModule.tokenManager(
        gh<_i361.Dio>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i130.SetTourPoints>(
      () => _i130.SetTourPoints(gh<_i438.TourTrackingRepository>()),
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
    gh.lazySingleton<_i193.TourDataSource>(
      () => _i193.TourDataSourceImpl(gh<_i455.ApiClient>()),
    );
    gh.lazySingleton<_i870.TourRepository>(
      () =>
          _i810.TourRepositoryImpl(tourDataSource: gh<_i870.TourDataSource>()),
    );
    gh.lazySingleton<_i718.MapDataSource>(
      () => _i718.CreatorDataSourceImpl(gh<_i455.ApiClient>()),
    );
    gh.lazySingleton<_i864.MapRepository>(
      () => _i943.MapRepositoryImpl(mapDataSource: gh<_i864.MapDataSource>()),
    );
    gh.lazySingleton<_i430.CheckAuth>(
      () => _i430.CheckAuth(gh<_i681.AuthRepository>()),
    );
    gh.lazySingleton<_i211.DeleteUser>(
      () => _i211.DeleteUser(gh<_i681.AuthRepository>()),
    );
    gh.lazySingleton<_i812.Login>(
      () => _i812.Login(gh<_i681.AuthRepository>()),
    );
    gh.lazySingleton<_i308.Logout>(
      () => _i308.Logout(gh<_i681.AuthRepository>()),
    );
    gh.lazySingleton<_i321.Register>(
      () => _i321.Register(gh<_i681.AuthRepository>()),
    );
    gh.lazySingleton<_i1050.SendPasswordRecoveryLink>(
      () => _i1050.SendPasswordRecoveryLink(gh<_i681.AuthRepository>()),
    );
    gh.lazySingleton<_i86.GetTourPoints>(
      () => _i86.GetTourPoints(gh<_i864.MapRepository>()),
    );
    gh.lazySingleton<_i380.SearchTour>(
      () => _i380.SearchTour(gh<_i870.TourRepository>()),
    );
    gh.factory<_i125.MapBloc>(
      () => _i125.MapBloc(
        getTourPoints: gh<_i864.GetTourPoints>(),
        setTourPoints: gh<_i864.SetTourPoints>(),
        tourTrackingRepository: gh<_i864.TourTrackingRepository>(),
        mapDataSource: gh<_i864.MapDataSource>(),
      ),
    );
    gh.factory<_i879.TourBloc>(
      () => _i879.TourBloc(searchTour: gh<_i870.SearchTour>()),
    );
    gh.factory<_i291.AuthBloc>(
      () => _i291.AuthBloc(
        checkAuth: gh<_i983.CheckAuth>(),
        login: gh<_i983.Login>(),
        logout: gh<_i983.Logout>(),
        register: gh<_i983.Register>(),
        sendPasswordRecoveryLink: gh<_i983.SendPasswordRecoveryLink>(),
        deleteUser: gh<_i983.DeleteUser>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i259.RegisterModule {}
