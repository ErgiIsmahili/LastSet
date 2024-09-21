import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/presentation/root/pages/bloc/theme_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AppVectors.logo,
              height: 40,
              width: 40,
              colorFilter: ColorFilter.mode(
                colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.wb_sunny),
                    color: themeMode == ThemeMode.light
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    onPressed: () {
                      context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.nights_stay),
                    color: themeMode == ThemeMode.dark
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    onPressed: () {
                      context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                    },
                  ),
                ],
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent, // Make the background clear
        elevation: 0, // Remove shadow
      ),
      body: const Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
