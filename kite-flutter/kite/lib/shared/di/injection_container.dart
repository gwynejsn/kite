import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kite/features/auth/data/datasources/auth_data_source.dart';
import 'package:kite/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';
import 'package:kite/features/auth/presentation/controllers/login_controller.dart';
import 'package:kite/features/auth/presentation/controllers/register_controller.dart';
import 'package:kite/shared/networks/jwt_service.dart';
import 'package:kite/shared/networks/jwt_service_imp.dart';
import 'package:kite/shared/security/encryption_service.dart';
import 'package:kite/shared/security/simple_e2ee_service.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSource(sl<http.Client>()),
  );

  sl.registerLazySingleton<JwtService>(() => JwtServiceImp());

  sl.registerLazySingleton<EncryptionService>(() => SimpleE2eeService());

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthDataSource>(),
      sl<JwtService>(),
      sl<EncryptionService>(),
    ),
  );

  sl.registerFactory<LoginController>(
    () => LoginController(sl<AuthRepository>()),
  );

  sl.registerFactory<RegisterController>(
    () => RegisterController(sl<AuthRepository>()),
  );
}
