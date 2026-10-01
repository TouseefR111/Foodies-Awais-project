import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String userKeyId = "USERKEYID";
  static const String userKeyName = "USERKEYNAME";
  static const String userKeyEmail = "USERKEYEMAIL";
  static const String userKeyContact = "USERKEYCONTACT";

  // Save user ID
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKeyId, userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyId);
  }

  // Save user name
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKeyName, name);
  }

  // Get user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyName);
  }

  // Save user email
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKeyEmail, email);
  }

  // Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyEmail);
  }

  // Save user contact
  Future<void> saveUserContact(String contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKeyContact, contact);
  }

  // Get user contact
  Future<String?> getUserContact() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyContact);
  }

  // Save all user information
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
    required String contact,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(userKeyId, userId);
    await prefs.setString(userKeyName, name);
    await prefs.setString(userKeyEmail, email);
    await prefs.setString(userKeyContact, contact);
  }

  // Clear saved user information during logout
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKeyId);
    await prefs.remove(userKeyName);
    await prefs.remove(userKeyEmail);
    await prefs.remove(userKeyContact);
  }
}
