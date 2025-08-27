import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common_header.dart';
import '../models/user.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String _profileImagePath = 'assets/images/profile_img.png';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final user = await UserManager.loadCurrentUser();
      if (user != null) {
        setState(() {
          firstNameController.text = user.firstName;
          lastNameController.text = user.lastName;
          phoneController.text = user.phone;
          emailController.text = user.email;
          addressController.text = user.address;
          _profileImagePath = user.profileImagePath;
        });
        // Update the global currentUser as well
        currentUser = user;
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback to existing currentUser if available
      if (currentUser != null) {
        setState(() {
          firstNameController.text = currentUser!.firstName;
          lastNameController.text = currentUser!.lastName;
          phoneController.text = currentUser!.phone;
          emailController.text = currentUser!.email;
          addressController.text = currentUser!.address;
          _profileImagePath = currentUser!.profileImagePath;
        });
      }
    }
  }

  ImageProvider _getProfileImage() {
    if (_profileImagePath.startsWith('assets/')) {
      return AssetImage(_profileImagePath);
    } else if (_profileImagePath.startsWith('base64:')) {
      // Handle base64 encoded images
      try {
        final base64String =
            _profileImagePath.substring(7); // Remove 'base64:' prefix
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        print('Error loading base64 image: $e');
        return const AssetImage('assets/images/profile_img.png');
      }
    } else {
      // This is a file path
      try {
        return FileImage(File(_profileImagePath));
      } catch (e) {
        print('Error loading file image: $e');
        return const AssetImage('assets/images/profile_img.png');
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    if (currentUser == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final assetPath = await UserManager.updateUserProfileImageFromXFile(
            currentUser!.username, image);

        setState(() {
          _profileImagePath = assetPath;
          _isLoading = false;
        });

        // Update the global currentUser immediately to refresh header
        if (currentUser != null) {
          currentUser!.profileImagePath = assetPath;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fotografija je uspešno promenjena!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri promeni fotografije: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: const CommonHeader(currentPage: 'profile'),
      body: Column(
        children: [
          const PurpleDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Podešavanja profila",
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 24 : 40),
                    // Profile section
                    isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (currentUser == null) return;

    // Validate fields
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Molimo popunite sva obavezna polja"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated user object preserving userType
      final updatedUser = User(
        username: currentUser!.username,
        password: currentUser!.password,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImagePath: _profileImagePath,
        userType: currentUser!.userType, // Preserve the user type
      );

      // Save to persistent storage
      await UserManager.updateUser(updatedUser);

      // Update the global currentUser variable
      currentUser = updatedUser;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil je uspešno ažuriran!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Force rebuild by navigating with replacement to refresh the header
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri čuvanju: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() async {
    await UserManager.clearCurrentUser();
    currentUser = null;

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Profile image and info section
        Column(
          children: [
            CircleAvatar(
              radius: 50, // Smaller radius for mobile
              backgroundImage: _getProfileImage(),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading profile image: $exception');
              },
            ),
            const SizedBox(height: 12),
            Text(
              "${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              currentUser?.userType == 'organizator'
                  ? 'Organizator'
                  : 'Korisnik',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons in a row for mobile
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _isLoading ? null : _changeProfilePicture,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.camera_alt,
                          color: Colors.blue, size: 18),
                  label: Text(
                    _isLoading ? "Čuvam..." : "Promeni fotografiju",
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red, size: 16),
                  label: const Text(
                    "Odjavi se",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Form fields section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Name
            _buildMobileTextField("Ime", firstNameController),
            const SizedBox(height: 16),
            // Last Name
            _buildMobileTextField("Prezime", lastNameController),
            const SizedBox(height: 16),
            // Phone
            _buildMobileTextField("Broj telefona", phoneController),
            const SizedBox(height: 16),
            // Email
            _buildMobileTextField("Email", emailController),
            const SizedBox(height: 16),
            // Address
            _buildMobileTextField("Adresa", addressController),
            const SizedBox(height: 32),
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Sačuvaj izmene",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Otkaži",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Profile image and info
        Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _getProfileImage(),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading profile image: $exception');
              },
            ),
            const SizedBox(height: 16),
            Text(
              "${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentUser?.userType == 'organizator'
                  ? 'Organizator'
                  : 'Korisnik',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _isLoading ? null : _changeProfilePicture,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.camera_alt, color: Colors.blue),
              label: Text(
                _isLoading ? "Čuvam..." : "Promeni fotografiju",
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                _logout();
              },
              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
              label: const Text(
                "Odjavi se",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 60),
        // Right side - Form fields
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row - First Name and Last Name
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ime",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Prezime",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Second row - Phone and Email
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Broj telefona",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Third row - Address (full width)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Adresa",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Otkaži",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Sačuvaj izmene",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
