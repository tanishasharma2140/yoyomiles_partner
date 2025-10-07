import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserViewModel with ChangeNotifier {

  Future<bool> saveUser(int userId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt('token', userId);
    notifyListeners();
    return true;
  }
  Future<int?> getUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    int? token = sp.getInt('token');
    return token;
  }
  Future<bool> remove() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove('token');
    return true;
  }

}