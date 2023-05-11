import 'package:shared_preferences/shared_preferences.dart';

class SPF{
  //KEY
  static String userLogInKey = "LogInKey";

  //Getter
  static Future<bool?> getLogInStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(userLogInKey);
  }

  //Setter
  static Future<bool> saveUserLogInStatus(bool isUserLogIn) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(userLogInKey, isUserLogIn);
  }
}