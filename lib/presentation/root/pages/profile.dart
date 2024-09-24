import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/common/helpers/is_dark_mode.dart';
import 'package:myapp/presentation/root/widgets/main_appbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      setState(() => _isLoading = true);
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String? profilePicture = userData.data()?['profilePicture'] as String?;

      if (profilePicture == null || profilePicture.isEmpty) {
        final storageRef = FirebaseStorage.instance.ref().child('user_profiles/default_profile.jpg');
        profilePicture = await storageRef.getDownloadURL();
      }

      setState(() {
        _profileImageUrl = profilePicture;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _profileImageUrl = null;
        _isLoading = false;
      });
    }
  }

 Future<void> _updateProfilePicture() async {
    if (_isPickerActive) {
      _showSnackBar('Image picker is already active');
      return;
    }

    setState(() => _isPickerActive = true);

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isLoading = true;
        });
        await _uploadImageToFirebase();
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: ${e.toString()}');
    } finally {
      setState(() => _isPickerActive = false);
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_imageFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final profilePicRef = storageRef.child('user_profiles/${user.uid}.jpg');

      await profilePicRef.putFile(_imageFile!);
      final downloadUrl = await profilePicRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profilePicture': downloadUrl,
      });

      setState(() {
        _profileImageUrl = downloadUrl;
        _isLoading = false;
      });

      _showSnackBar('Profile picture updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update profile picture: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      _showSnackBar('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const MainAppBar(),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final fullName = userData['fullName'] as String? ?? user.displayName ?? 'N/A';

                return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _updateProfilePicture,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (_profileImageUrl != null
                                        ? NetworkImage(_profileImageUrl!)
                                        : null) as ImageProvider?,
                                child: (_profileImageUrl == null && _imageFile == null)
                                    ? const Icon(Icons.person, size: 60)
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: Icon(Icons.camera_alt, size: 18, color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: isDarkMode ? Colors.white : Colors.black,
                        ),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
              }
            ),
    );
  }
}