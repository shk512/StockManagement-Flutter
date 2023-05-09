import 'package:shared_preferences/shared_preferences.dart';

class SPF{
  //KEY
  static String userLogInKey = "LogInKey";
  static String userIdKey="userId";
  static String companyIdKey="companyId";

  //Getter
  static Future<bool?> getLogInStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(userLogInKey);
  }
  static Future<String?> getUserId()async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    return sp.getString(userIdKey);
  }
  static Future<String?> getCompanyId()async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    return sp.getString(companyIdKey);
  }

  //Setter
  static Future<bool> saveUserLogInStatus(bool isUserLogIn) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(userLogInKey, isUserLogIn);
  }
  static Future saveUserId(String userId)async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    await sp.setString(userIdKey, userId);
  }
  static Future saveCompanyId(String companyId)async{
    SharedPreferences sp=await SharedPreferences.getInstance();
    await sp.setString(companyIdKey,companyId);
  }
}