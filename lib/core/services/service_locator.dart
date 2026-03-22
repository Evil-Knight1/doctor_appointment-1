import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:doctor_appointment/core/config/app_config.dart';
import 'package:doctor_appointment/core/config/env.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doctor_appointment/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/login_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/get_cached_session_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<AppConfig>(() {
    final config = AppConfig(apiUrl: Env.apiUrl);
    config.validate();
    return config;
  });

  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: getIt<AppConfig>().apiUrl,
        receiveDataWhenStatusError: true,
      ),
    ),
  );

  getIt.registerLazySingleton<ApiService>(() => ApiServiceImpl(getIt<Dio>()));
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SecureStorageService>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => GetCachedSessionUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => RegisterPatientUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => RefreshTokenUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      registerPatientUseCase: getIt<RegisterPatientUseCase>(),
    ),
  );
}
