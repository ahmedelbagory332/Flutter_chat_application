import 'package:shared_preferences/shared_preferences.dart';

class LoginStatus{


  readStaus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'status';
    // ignore: undefined_method
    final value = prefs.getBool(key) ?? false;

    return value;
  }

  writeStaus(bool status)async  {
    final prefs = await SharedPreferences.getInstance();
    final key = 'status';
    // ignore: undefined_method
    prefs.setBool(key, status);
  }


}