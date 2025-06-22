import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getUser();

    setState(() {
      _firstNameController.text = user!.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _emailController.text = user.email;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black87,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [const SizedBox(height: 12), _buildProfileView()],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person, color: AppColors.primaryBlue),
          title: Text(
            '${_firstNameController.text} ${_lastNameController.text}',
            style: const TextStyle(fontSize: 18, color: AppColors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.email, color: AppColors.primaryBlue),
          title: Text(
            _emailController.text,
            style: const TextStyle(fontSize: 16, color: AppColors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.phone, color: AppColors.primaryBlue),
          title: Text(
            _phoneController.text,
            style: const TextStyle(fontSize: 16, color: AppColors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: AppColors.primaryBlue),
          title: Text(
            _addressController.text,
            style: const TextStyle(fontSize: 16, color: AppColors.white),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Coming soon')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 20, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
