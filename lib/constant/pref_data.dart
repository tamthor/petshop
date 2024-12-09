import 'package:shared_preferences/shared_preferences.dart';
class PrefData {

    static String prefName = "com.example.shopping";
    static String introAvailable = prefName + "isIntroAvailable";
    static String isLoggedIn = prefName + "isLoggedIn";
    static String token = prefName + "token";
    static String userEmail = prefName + "userEmail";
    static String userPassword = prefName + "userPassword";

    static Future<SharedPreferences> getPrefInstance() async { SharedPreferences preferences = await SharedPreferences.getInstance(); // avait SharedPreferences.getInstance();

    return preferences;
    }
    static Future<bool> isIntroAvailable() async { 
      SharedPreferences preferences = await getPrefInstance(); 
      bool isIntroAvailable = preferences.getBool(introAvailable) ?? true; 
      return isIntroAvailable;
    }
    static setIntroAvailable(bool avail) async { 
      SharedPreferences preferences = await getPrefInstance(); 
      preferences.setBool (introAvailable, avail);
    }
    static setLogin(bool avail) async {
      SharedPreferences preferences = await getPrefInstance(); 
      preferences.setBool (isLoggedIn, avail);
      }

    static Future<bool> istogin() async {
      SharedPreferences preferences = await getPrefInstance(); 
      bool isIntroAvailable = preferences.getBool (isLoggedIn) ?? false;
      return isIntroAvailable;
    }
    static setToken(String mtoken) async {
      SharedPreferences preferences = await getPrefInstance(); 
      preferences.setString(token, mtoken);
    }
    static Future<String> getToken() async {
      SharedPreferences preferences = await getPrefInstance(); 
      String tokenvalue = preferences.getString(token) ?? "";
      return tokenvalue;
    }

    static setUserRegistration(String email, String password) async {
      SharedPreferences preferences = await getPrefInstance();
      preferences.setString(userEmail, email);
      preferences.setString(userPassword, password);
    }

    static Future<Map<String, String>> getUserRegistration() async {
      SharedPreferences preferences = await getPrefInstance();
      String email = preferences.getString(userEmail) ?? "";
      String password = preferences.getString(userPassword) ?? "";
      return {'email': email, 'password': password};
    }
}