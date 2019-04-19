import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static final String endPoint = 'login';

  // Keys to store and fetch data from SharedPreferences
  static String authTokenKey = 'auth_token';

  static final now = new DateTime.now();
  static final date = now.add(new Duration(days: 2));

  static String getKey(String type, SharedPreferences prefs) {
    return prefs.getString(type);
  }

  static int getDate(SharedPreferences prefs) {
    return prefs.getInt("expired_date");
  }

  static insertDetails(SharedPreferences prefs, var response) {
    prefs.setString(authTokenKey, response['auth_token']);
    prefs.setInt('expired_date', date.toUtc().millisecondsSinceEpoch);
  }
}
