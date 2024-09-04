import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/common/helpers/is_dark_mode.dart';
import 'package:myapp/common/widgets/appbar/app_bar.dart';
import 'package:myapp/common/widgets/button/basic_app_button.dart';
import 'package:myapp/core/configs/assets/app_images.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/core/configs/theme/app_colors.dart';
import 'package:myapp/presentation/auth/pages/signin.dart';
import 'package:myapp/presentation/auth/pages/signup.dart';

class SignupOrSigninPage extends StatelessWidget{
  const SignupOrSigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    
    return Scaffold(
      body: Stack(
        children: [
          const BasicAppBar(),
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(
              AppVectors.topPattern,
              colorFilter: ColorFilter.mode(
                          isDarkMode ? Colors.white : Colors.black, BlendMode.srcIn)
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(
                AppImages.authBG,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child:Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                      AppVectors.logo,
                      colorFilter: ColorFilter.mode(
                          isDarkMode ? Colors.white : Colors.black, BlendMode.srcIn),
                    ),
                  const SizedBox(
                    height: 55,
                  ),
                  Text(
                    "Focus on your workout",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.black
                    ),
                  ),
                  const SizedBox(
                    height: 21,
                  ),
                  const Text(
                    "Stop relying on memory ",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.grey
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 500,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BasicAppButton(
                          onPressed: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (BuildContext context) => SignupPage()
                              ),
                            );
                          }, 
                          title: 'Register',
                        ),
                      ),
                      const SizedBox(width: 20,),
                      Expanded(
                        flex:1,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                            ),
                            minimumSize: const Size.fromHeight(80)
                          ),
                          onPressed: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (BuildContext context) => SigninPage()
                              ),
                            );
                          }, 
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}