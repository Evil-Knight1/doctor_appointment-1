import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/logging/api_logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:doctor_appointment/core/config/app_config.dart';
import 'package:doctor_appointment/core/config/env.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/core/services/auth_token_interceptor.dart';
import 'package:doctor_appointment/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doctor_appointment/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/login_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/get_cached_session_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/register_doctor_usecase.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/doctors_remote_data_source.dart';
import 'package:doctor_appointment/features/doctors/data/repositories/doctors_repository_impl.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:doctor_appointment/features/doctors/domain/usecases/search_doctors_usecase.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:doctor_appointment/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:doctor_appointment/features/profile/domain/repositories/profile_repository.dart';
import 'package:doctor_appointment/features/profile/domain/usecases/get_patient_profile_usecase.dart';
import 'package:doctor_appointment/features/profile/domain/usecases/update_patient_profile_usecase.dart';
import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';
import 'package:doctor_appointment/features/appointment/data/datasources/appointment_remote_data_source.dart';
import 'package:doctor_appointment/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/create_appointment_usecase.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/get_my_appointments_usecase.dart';
import 'package:doctor_appointment/features/appointment/logic/appointment_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/specializations_remote_data_source.dart';
import 'package:doctor_appointment/features/doctors/data/repositories/specializations_repository_impl.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/specializations_repository.dart';
import 'package:doctor_appointment/features/doctors/domain/usecases/get_specializations_usecase.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/data/datasources/doctor_stats_remote_data_source.dart';
import 'package:doctor_appointment/features/doctor_flow/data/repositories/doctor_stats_repository_impl.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_stats_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_profile_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<AppConfig>(() {
    final config = AppConfig(apiUrl: Env.apiUrl);
    config.validate();
    return config;
  });

  getIt.registerLazySingleton<LogService>(() => LogService());

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
  getIt.registerLazySingleton<AuthTokenInterceptor>(
    () => AuthTokenInterceptor(
      localDataSource: getIt<AuthLocalDataSource>(),
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      dio: getIt<Dio>(),
    ),
  );
  getIt<Dio>().interceptors.addAll([
    getIt<AuthTokenInterceptor>(),
    ApiLoggingInterceptor(getIt<LogService>()),
  ]);
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
  getIt.registerLazySingleton(
    () => RegisterDoctorUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      registerPatientUseCase: getIt<RegisterPatientUseCase>(),
      registerDoctorUseCase: getIt<RegisterDoctorUseCase>(),
    ),
  );

  getIt.registerLazySingleton<DoctorsRemoteDataSource>(
    () => DoctorsRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<DoctorsRepository>(
    () => DoctorsRepositoryImpl(getIt<DoctorsRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => SearchDoctorsUseCase(getIt<DoctorsRepository>()),
  );
  getIt.registerFactory(
    () => DoctorsCubit(searchDoctorsUseCase: getIt<SearchDoctorsUseCase>()),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => GetPatientProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdatePatientProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory(
    () => ProfileCubit(
      getPatientProfileUseCase: getIt<GetPatientProfileUseCase>(),
      updatePatientProfileUseCase: getIt<UpdatePatientProfileUseCase>(),
    ),
  );

  getIt.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(getIt<AppointmentRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => CreateAppointmentUseCase(getIt<AppointmentRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetMyAppointmentsUseCase(getIt<AppointmentRepository>()),
  );
  getIt.registerFactory(
    () => AppointmentCubit(
      createAppointmentUseCase: getIt<CreateAppointmentUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => AppointmentsCubit(
      getMyAppointmentsUseCase: getIt<GetMyAppointmentsUseCase>(),
    ),
  );

  // Specializations
  getIt.registerLazySingleton<SpecializationsRemoteDataSource>(
    () => SpecializationsRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SpecializationsRepository>(
    () => SpecializationsRepositoryImpl(getIt<SpecializationsRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => GetSpecializationsUseCase(getIt<SpecializationsRepository>()),
  );
  getIt.registerFactory(
    () => SpecializationsCubit(
      getSpecializationsUseCase: getIt<GetSpecializationsUseCase>(),
    ),
  );

  // Doctor Statistics
  getIt.registerLazySingleton<DoctorStatsRemoteDataSource>(
    () => DoctorStatsRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<DoctorStatsRepository>(
    () => DoctorStatsRepositoryImpl(getIt<DoctorStatsRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => GetDoctorStatsUseCase(getIt<DoctorStatsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDoctorProfileUseCase(getIt<DoctorStatsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDoctorAppointmentsUseCase(getIt<DoctorStatsRepository>()),
  );
  getIt.registerFactory(
    () => DoctorStatsCubit(
      getDoctorStatsUseCase: getIt<GetDoctorStatsUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => DoctorProfileCubit(
      getDoctorProfileUseCase: getIt<GetDoctorProfileUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => DoctorAppointmentsCubit(
      getDoctorAppointmentsUseCase: getIt<GetDoctorAppointmentsUseCase>(),
    ),
  );
}
