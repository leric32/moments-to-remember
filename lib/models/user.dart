import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class User {
  final String username;
  final String password;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  String profileImagePath;
  String userType; // 'customer' or 'organizator'

  User({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.profileImagePath = 'assets/images/profile_img.png',
    this.userType = 'customer', // Default to customer
  });

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImagePath': profileImagePath,
      'userType': userType,
    };
  }

  // Create User from JSON
  static Future<User> fromJsonAsync(Map<String, dynamic> json) async {
    final username = json['username'] ?? '';
    final profileImagePath = await UserManager.loadProfileImage(username);

    return User(
      username: username,
      password: json['password'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profileImagePath: profileImagePath,
      userType: json['userType'] ?? 'customer',
    );
  }

  // Create User from JSON (sync version for backwards compatibility)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profileImagePath:
          json['profileImagePath'] ?? 'assets/images/profile_img.png',
      userType: json['userType'] ?? 'customer',
    );
  }

  // Update user information
  void updateInfo({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? profileImagePath,
  }) {
    if (firstName != null) this.firstName = firstName;
    if (lastName != null) this.lastName = lastName;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (address != null) this.address = address;
    if (profileImagePath != null) this.profileImagePath = profileImagePath;
  }
}

// User management class
class UserManager {
  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'current_user';

  // Save all users to SharedPreferences
  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => user.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(usersJson));
  }

  // Load all users from SharedPreferences
  static Future<List<User>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey);

    if (usersString != null) {
      final usersJson = jsonDecode(usersString) as List;
      return usersJson.map((json) => User.fromJson(json)).toList();
    }

    // Return default users if no data found
    return [
      User(
        username: 'pavle123',
        password: 'test123',
        firstName: 'Pavle',
        lastName: 'Pavlović',
        email: 'pavle.pavlovic@example.com',
        phone: '+381 91 234 5678',
        address: 'Knez Mihailova 42, Beograd',
        userType: 'customer',
      ),
      User(
        username: 'admin123',
        password: 'admin123',
        firstName: 'Marko',
        lastName: 'Organizator',
        email: 'marko.organizator@example.com',
        phone: '+381 92 345 6789',
        address: 'Terazije 15, Beograd',
        userType: 'organizator',
      ),
    ];
  }

  // Save current user
  static Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  // Load current user
  static Future<User?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_currentUserKey);

    if (userString != null) {
      final userJson = jsonDecode(userString);
      final user = User.fromJson(userJson);
      // Load the actual profile image path
      user.profileImagePath = await loadProfileImage(user.username);
      return user;
    }

    return null;
  }

  // Update user profile image using XFile
  static Future<String> updateUserProfileImageFromXFile(
      String username, XFile imageFile) async {
    final newPath = await saveProfileImageFromXFile(imageFile, username);

    // Update current user if it matches
    if (currentUser != null && currentUser!.username == username) {
      currentUser!.profileImagePath = newPath;
      await saveCurrentUser(currentUser!);
    }

    // Update in users list
    final usersList = await loadUsers();
    final index = usersList.indexWhere((u) => u.username == username);
    if (index != -1) {
      usersList[index].profileImagePath = newPath;
      await saveUsers(usersList);
    }

    return newPath;
  }

  static Future<String> saveProfileImageFromXFile(
      XFile imageFile, String username) async {
    try {
      // Read the image file bytes directly from XFile
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // Store the base64 string with a prefix to identify it
      final prefs = await SharedPreferences.getInstance();
      final profileImageKey = 'profile_image_$username';
      final base64Path = 'base64:$base64String';
      await prefs.setString(profileImageKey, base64Path);

      print('Successfully saved profile image as base64 for $username');
      return base64Path;
    } catch (e) {
      print('Error saving profile image: $e');
      return 'assets/images/profile_img.png'; // fallback to default
    }
  }

  // Update user profile image
  static Future<String> updateUserProfileImage(
      String username, String imagePath) async {
    final newPath = await saveProfileImage(imagePath, username);

    // Update current user if it matches
    if (currentUser != null && currentUser!.username == username) {
      currentUser!.profileImagePath = newPath;
      await saveCurrentUser(currentUser!);
    }

    // Update in users list
    final usersList = await loadUsers();
    final index = usersList.indexWhere((u) => u.username == username);
    if (index != -1) {
      usersList[index].profileImagePath = newPath;
      await saveUsers(usersList);
    }

    return newPath;
  }

  // Update user in the users list and save
  static Future<void> updateUser(User updatedUser) async {
    final usersList = await loadUsers();
    final index =
        usersList.indexWhere((user) => user.username == updatedUser.username);

    if (index != -1) {
      usersList[index] = updatedUser;
      await saveUsers(usersList);
      await saveCurrentUser(updatedUser);
    }
  }

  // Clear current user (logout)
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Save profile image and return the new path
  static Future<String> saveProfileImage(
      String imagePath, String username) async {
    try {
      // Create a unique filename for this user
      final String fileName = '${username}_profile.jpg';

      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final String appDirPath = directory.path;
      final String fullPath = '$appDirPath/$fileName';

      // Copy the selected image to app directory
      final sourceFile = File(imagePath);
      if (!await sourceFile.exists()) {
        print('Source image file does not exist: $imagePath');
        return 'assets/images/profile_img.png';
      }

      await sourceFile.copy(fullPath);

      // Store the app directory path
      final prefs = await SharedPreferences.getInstance();
      final profileImageKey = 'profile_image_$username';
      await prefs.setString(profileImageKey, fullPath);

      print('Successfully saved profile image to: $fullPath');
      return fullPath;
    } catch (e) {
      print('Error saving profile image: $e');
      return 'assets/images/profile_img.png'; // fallback to default
    }
  }

  // Load profile image path for a user
  static Future<String> loadProfileImage(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileImageKey = 'profile_image_$username';
      return prefs.getString(profileImageKey) ??
          'assets/images/profile_img.png';
    } catch (e) {
      print('Error loading profile image: $e');
      return 'assets/images/profile_img.png';
    }
  }
}

// Global variables
List<User> users = [];
User? currentUser;

// Initialize users data
Future<void> initializeUsers() async {
  users = await UserManager.loadUsers();
  currentUser = await UserManager.loadCurrentUser();
}
