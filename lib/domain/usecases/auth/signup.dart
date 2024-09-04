import 'package:dartz/dartz.dart';
import 'package:myapp/core/configs/usecases/usecase.dart';
import 'package:myapp/data/models/auth/create_user_req.dart';
import 'package:myapp/domain/repository/auth/auth.dart';
import 'package:myapp/service_locator.dart';

class SignupUseCase implements Usecase<Either,CreateUserReq>{
  @override
  Future<Either> call({CreateUserReq ? params}) async {
    return sl<AuthRepository>().signup(params!);
  }
  
}