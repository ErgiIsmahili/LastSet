import 'package:get_it/get_it.dart';
import 'package:myapp/data/repository/auth/auth_repository_impl.dart';
import 'package:myapp/data/sources/auth/auth_firebase_service.dart';
import 'package:myapp/domain/repository/auth/auth.dart';
import 'package:myapp/domain/usecases/auth/signin.dart';
import 'package:myapp/domain/usecases/auth/signup.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl(),
  );

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<AuthFirebaseService>()),
  );

  sl.registerSingleton<SignupUseCase>(
    SignupUseCase(),
  );

   sl.registerSingleton<SigninUseCase>(
    SigninUseCase(),
  );
}
