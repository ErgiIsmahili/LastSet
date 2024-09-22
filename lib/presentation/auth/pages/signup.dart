import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myapp/common/widgets/appbar/app_bar.dart';
import 'package:myapp/common/widgets/button/basic_app_button.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/data/models/auth/create_user_req.dart';
import 'package:myapp/domain/usecases/auth/signup.dart';
import 'package:myapp/presentation/auth/pages/signin.dart';
import 'package:myapp/presentation/root/pages/root.dart';
import 'package:myapp/service_locator.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final String _defaultProfilePicture = 'https://example.com/default_profile_pic.png';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: _signinText(context),
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
            _registerText(context),
            const SizedBox(height: 50),
            _fullNameField(context),
            const SizedBox(height: 20),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: () => _handleSignup(context),
              title: 'Create Account',
            )
          ],
        ),
      ),
    );
  }

  Widget _registerText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      'Register',
      style: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullName,
      decoration: const InputDecoration(
        hintText: 'Full Name',
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme,
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
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

  Widget _signinText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Do you have an account? ',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SigninPage(),
                ),
              );
            },
            child: Text(
              'Sign In',
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

  void _handleSignup(BuildContext context) async {
    var result = await sl<SignupUseCase>().call(
      params: CreateUserReq(
        fullName: _fullName.text.toString(),
        email: _email.text.toString(),
        password: _password.text.toString(),
        profilePicture: _defaultProfilePicture,
      ),
    );
    result.fold(
      (l) {
        var snackbar = SnackBar(content: Text(l));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      (r) async {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_fullName.text.toString());
        }
        
        await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
          'fullName': _fullName.text.toString(),
          'email': _email.text.toString(),
          'profilePicture': _defaultProfilePicture,
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const RootPage()),
          (route) => false,
        );
      },
    );
  }
}