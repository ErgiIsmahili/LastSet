import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/presentation/auth/pages/signup_or_signin.dart';

class SplashPage extends StatefulWidget{
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState(){
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          AppVectors.logoWord
        )
      ),
    );
  }

  Future<void> redirect() async {
  await Future.delayed(const Duration(seconds: 2));
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const SignupOrSigninPage(),
      ),
    );
  }
}

}