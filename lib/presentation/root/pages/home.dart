import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.topLeft,
          child: SvgPicture.asset(
            AppVectors.logo,
            height: 40,
            width: 40,
            colorFilter: ColorFilter.mode(
              colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Make the background clear
        elevation: 0, // Remove shadow
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}
