import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'https://ib.jamalmoallart.com/api/v2';
  User? _cachedUser;

  Future<User?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user'); // Clean up previous user data
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'phone': phone,
              'address': address,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);
      print(
        'Register Response: ${response.statusCode} - ${response.body}',
      ); // Debug print

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['state'] == true) {
          final userData = responseBody['data'] as Map<String, dynamic>?;
          if (userData != null) {
            final user = User.fromJson(userData);
            await prefs.setString('user', jsonEncode(user.toJson()));
            _cachedUser = user;
            print(
              'Saved user to SharedPreferences: ${jsonEncode(user.toJson())}',
            ); // Debug print
            return user;
          } else {
            throw Exception('Invalid response: Missing user data');
          }
        } else {
          throw Exception(
            responseBody['message'] ?? 'Registration failed: Unknown error',
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 422) {
        // Handle validation errors or email already taken
        final errorMessage = responseBody['data'] is String
            ? responseBody['data']
            : responseBody['message'] ?? 'Registration failed: Invalid input';
        throw Exception(errorMessage);
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e'); // Debug print
      rethrow; // Rethrow to allow UI to catch and display the error
    }
  }

  Future<User?> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);
      print(
        'Login Response: ${response.statusCode} - ${response.body}',
      ); // Debug print

      if (response.statusCode == 200) {
        if (responseBody['state'] == true) {
          final userData = responseBody['data'] as Map<String, dynamic>?;
          if (userData != null) {
            final user = User.fromJson(userData);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user', jsonEncode(user.toJson()));
            print(
              'Saved user to SharedPreferences: ${jsonEncode(user.toJson())}',
            ); // Debug print
            if (rememberMe) {
              await prefs.setBool('remember_me', true);
            } else {
              await prefs.remove('remember_me');
            }
            _cachedUser = user;
            return user;
          } else {
            throw Exception('Invalid response: Missing user data');
          }
        } else {
          throw Exception(
            'Login failed: ${responseBody['message'] ?? 'Invalid email or password'}',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid email or password');
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e'); // Debug print
      throw Exception('Error during login: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // مسح بيانات الطلبات عند تسجيل الخروج
      await prefs.remove('orders');

      final userJson = prefs.getString('user');
      if (userJson == null) {
        print('No user found for logout'); // Debug print
        return;
      }

      final user = User.fromJson(jsonDecode(userJson));
      final response = await http
          .get(
            Uri.parse('$_baseUrl/logout'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${user.token}',
            },
          )
          .timeout(const Duration(seconds: 10));

      print(
        'Logout Response: ${response.statusCode} - ${response.body}',
      ); // Debug print

      // Clear local data regardless of backend response
      await prefs.remove('user');
      await prefs.remove('remember_me');
      _cachedUser = null;

      if (response.statusCode == 200) {
        print('User logged out successfully'); // Debug print
      } else {
        print(
          'Backend logout failed, but local data cleared: ${response.body}',
        ); // Debug print
      }
    } catch (e) {
      print('Error during logout: $e'); // Debug print
      // Clear local data even if error occurs
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('remember_me');
      await prefs.remove('orders'); // تأكد من مسح الطلبات هنا أيضاً
      _cachedUser = null;
      print('Cleared local data due to logout error'); // Debug print
    }
  }

  Future<User?> getUser() async {
    try {
      if (_cachedUser != null) {
        print('Returning cached user: ${_cachedUser!.email}'); // Debug print
        return _cachedUser;
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson == null) {
        print('No user found in SharedPreferences'); // Debug print
        return null;
      }

      final user = User.fromJson(jsonDecode(userJson));
      print(
        'Retrieved user from SharedPreferences: ${jsonEncode(user.toJson())}',
      ); // Debug print
      _cachedUser = user;
      return user;
    } catch (e) {
      print('Error fetching user: $e'); // Debug print
      return null;
    }
  }

  Future<User?> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/profile/update'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'phone': phone,
              'address': address,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);
      print(
        'Update Profile Response: ${response.statusCode} - ${response.body}',
      ); // Debug print

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['state'] == true) {
          final userData = responseBody['data'] as Map<String, dynamic>?;
          if (userData != null) {
            final user = User.fromJson(userData);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user', jsonEncode(user.toJson()));
            _cachedUser = user;
            print(
              'Saved updated user to SharedPreferences: ${jsonEncode(user.toJson())}',
            ); // Debug print
            return user;
          } else {
            throw Exception('Invalid response: Missing user data');
          }
        } else {
          throw Exception(
            'Profile update failed: ${responseBody['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error during profile update: $e'); // Debug print
      throw Exception('Error during profile update: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    print('isLoggedIn: ${user != null}'); // Debug print
    return user != null;
  }

  /// دالة لفحص حالة المستخدم ومسح الطلبات إذا لم يكن مسجل دخول أو لم يفعل "تذكرني"
  Future<void> cleanOrdersIfLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (userJson == null || !rememberMe) {
      // إذا لا يوجد مستخدم مسجل أو لم يفعل "تذكرني"
      await prefs.remove('orders'); // مسح بيانات الطلبات
      print('Orders cleared because user is logged out or not remembered.');
    }
  }
}
