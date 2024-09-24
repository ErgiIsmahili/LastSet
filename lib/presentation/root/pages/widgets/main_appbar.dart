import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/presentation/root/pages/bloc/theme_cubit.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      centerTitle: true,
      toolbarHeight: kToolbarHeight, 
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: SvgPicture.asset(
          AppVectors.logo,
          height: 100,
          width: 100,
          colorFilter: ColorFilter.mode(
            colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
      ),
      titleSpacing: 0,
      title: SvgPicture.asset(
        AppVectors.title,
        height: 100,
        width: 100,
        colorFilter: ColorFilter.mode(
          colorScheme.onSurface,
          BlendMode.srcIn,
        ),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
