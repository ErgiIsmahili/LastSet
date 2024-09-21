import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myapp/common/widgets/appbar/app_bar.dart';
import 'package:myapp/common/widgets/button/basic_app_button.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/data/models/auth/signin_user_req.dart';
import 'package:myapp/domain/usecases/auth/signin.dart';
import 'package:myapp/presentation/auth/pages/signup.dart';
import 'package:myapp/presentation/root/pages/root.dart';
import 'package:myapp/service_locator.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: _signupText(context),
      appBar: BasicAppBar(
        title: SvgPicture.asset(
          AppVectors.logoWord,
          height: 40,
          width: 40,
          colorFilter: ColorFilter.mode(
            colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _signinText(context),
            const SizedBox(height: 50),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: () => _handleSignin(context),
              title: 'Sign In',
            )
          ],
        ),
      ),
    );
  }

  Widget _signinText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      'Sign In',
      style: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Enter Email',
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme,
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Password',
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme,
      ),
    );
  }

  Widget _signupText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not A Member? ',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignupPage(),
                ),
              );
            },
            child: Text(
              'Register Now',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.onSurface,
                decorationThickness: 1,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _handleSignin(BuildContext context) async {
    var result = await sl<SigninUseCase>().call(
      params: SigninUserReq(
        email: _email.text.toString(),
        password: _password.text.toString(),
      ),
    );
    result.fold(
      (l) {
        var snackbar = SnackBar(content: Text(l));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      (r) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const RootPage()),
          (route) => false,
        );
      },
    );
  }
}