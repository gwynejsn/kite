import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kite/features/auth/data/datasources/auth_datasource.dart';
import 'package:kite/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';
import 'package:kite/features/auth/presentation/controllers/login_controller.dart';
import 'package:kite/features/auth/presentation/controllers/register_controller.dart';
import 'package:kite/features/conversation/data/datasources/conversation_datasource.dart';
import 'package:kite/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:kite/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/social/data/datasources/social_datasource.dart';
import 'package:kite/features/social/data/repositories/social_repository_impl.dart';
import 'package:kite/features/social/domain/repositories/social_repository.dart';
import 'package:kite/features/social/presentation/controllers/social_controller.dart';
import 'package:kite/shared/networks/dio_client.dart';
import 'package:kite/shared/networks/jwt_service.dart';
import 'package:kite/shared/networks/jwt_service_imp.dart';
import 'package:kite/shared/security/encryption_service.dart';
import 'package:kite/shared/security/simple_e2ee_service.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<JwtService>(() => JwtServiceImp());

  sl.registerLazySingleton<DioClient>(() => DioClient(sl<JwtService>()));
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSource(sl<Dio>()),
  );

  sl.registerLazySingleton<EncryptionService>(() => SimpleE2eeService());

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthDataSource>(),
      sl<JwtService>(),
      sl<EncryptionService>(),
    ),
  );

  sl.registerLazySingleton<ConversationDatasource>(
    () => ConversationDatasource(sl<Dio>()),
  );

  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(sl<ConversationDatasource>()),
  );

  sl.registerLazySingleton<SocialDatasource>(
    () => SocialDatasource(sl<Dio>()),
  );

  sl.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(sl<SocialDatasource>()),
  );

  sl.registerFactory<LoginController>(
    () => LoginController(sl<AuthRepository>()),
  );

  sl.registerFactory<RegisterController>(
    () => RegisterController(sl<AuthRepository>()),
  );

  sl.registerFactory<ConversationController>(
    () => ConversationController(sl<ConversationRepository>()),
  );

  sl.registerFactory<SocialController>(
    () => SocialController(sl<SocialRepository>()),
  );
}
