import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper{

  static String userKeyId = "USERKEYID";
  static String userKeyName = "USERKEYNAME";
  static String userKeyEmail = "USERKEYEMAIL";
  static String userKeyContact = "USERKEYCONTACT";




  Future<bool> saveUserId(String getUserId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userKeyId, getUserId);
  }

  Future<bool> saveUserName(String getUserName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userKeyName, getUserName);
  }

  Future<bool> saveUserContact(String getUserContact) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userKeyContact, getUserContact);
  }

  Future<bool> saveUserEmail(String getUserEmail) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userKeyEmail, getUserEmail);
  }

  Future<String?> getUserId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyId);
  }

  Future<String?> getUserName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyName);
  }

  Future<String?> getUserContact() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyContact);
  }

  Future<String?> getUserEmail() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKeyEmail);
  }

}