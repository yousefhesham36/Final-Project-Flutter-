import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  User? _cachedUser;

  Future<User?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final newUser = User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      password: password,
    );

    List<String> usersJson = prefs.getStringList('users') ?? [];

    print('Users before register: $usersJson'); 

    final existingUser = usersJson.firstWhere(
      (userStr) => User.fromJson(jsonDecode(userStr)).email == email,
      orElse: () => '',
    );

    if (existingUser.isNotEmpty) {
      throw Exception('This email already exists');
    }

    usersJson.add(jsonEncode(newUser.toJson()));
    await prefs.setStringList('users', usersJson);

    print('Users after register: $usersJson'); 

    await prefs.setString('user', jsonEncode(newUser.toJson()));
    _cachedUser = newUser;
    return newUser;
  }

  Future<User?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('users') ?? [];

    print(
      'Users at login: $usersJson',
    ); 

    for (final userStr in usersJson) {
      final user = User.fromJson(jsonDecode(userStr));
      if (user.email == email && user.password == password) {
        await prefs.setString('user', jsonEncode(user.toJson()));
        await prefs.setBool('remember_me', rememberMe);
        _cachedUser = user;
        return user;
      }
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('remember_me');
    await prefs.remove('orders');
    _cachedUser = null;
  }

  Future<User?> getUser() async {
    if (_cachedUser != null) return _cachedUser;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;

    final user = User.fromJson(jsonDecode(userJson));
    _cachedUser = user;
    return user;
  }

  Future<User?> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final usersJson = prefs.getStringList('users') ?? [];

    if (userJson == null) return null;

    final oldUser = User.fromJson(jsonDecode(userJson));

    final updatedUser = User(
      firstName: firstName,
      lastName: lastName,
      email: oldUser.email,
      phone: phone,
      address: address,
      password: oldUser.password,
    );

    final updatedUsers = usersJson.map((userStr) {
      final u = User.fromJson(jsonDecode(userStr));
      return (u.email == oldUser.email)
          ? jsonEncode(updatedUser.toJson())
          : userStr;
    }).toList();

    await prefs.setStringList('users', updatedUsers);
    await prefs.setString('user', jsonEncode(updatedUser.toJson()));
    _cachedUser = updatedUser;

    return updatedUser;
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }

  Future<void> cleanOrdersIfLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (userJson == null || !rememberMe) {
      await prefs.remove('orders');
    }
  }
}
