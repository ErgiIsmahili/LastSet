import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/core/configs/assets/app_vectors.dart';
import 'package:myapp/presentation/root/pages/bloc/theme_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final fullName = userData['fullName'] as String? ?? user.displayName ?? 'N/A';
              final email = user.email ?? 'N/A';
              final profilePicture = userData['profilePicture'] as String? ?? user.photoURL ?? '';
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profilePicture.isNotEmpty
                              ? NetworkImage(profilePicture)
                              : null,
                          child: profilePicture.isEmpty
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          fullName,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}