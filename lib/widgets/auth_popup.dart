import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthMode { welcome, login, register }

class AuthPopup extends StatefulWidget {
  const AuthPopup({super.key});

  @override
  State<AuthPopup> createState() => _AuthPopupState();
}

class _AuthPopupState extends State<AuthPopup> {
  final AuthService _authService = AuthService();
  AuthMode _currentMode = AuthMode.welcome;
  bool _isLoading = false;

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xF9DD9A00),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xAD572100), width: 10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xAD572100).withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentMode) {
      case AuthMode.welcome:
        return _buildWelcomeView();
      case AuthMode.login:
        return _buildLoginView();
      case AuthMode.register:
        return _buildRegisterView();
    }
  }

  Widget _buildWelcomeView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Play now or login to save your progress',
          style: TextStyle(
            fontSize: 20,
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Play as Guest button
        _buildCard(
          text: 'Play as Guest',
          onTap: _isLoading ? null : _handleGuestLogin,
        ),

        const SizedBox(height: 8),

        // Create Account button
        _buildCard(
          text: 'Create an Account',
          onTap: _isLoading
              ? null
              : () => setState(() => _currentMode = AuthMode.register),
        ),

        const SizedBox(height: 8),

        // Login button
        _buildCard(
          text: 'Login',
          onTap: _isLoading
              ? null
              : () => setState(() => _currentMode = AuthMode.login),
        ),

        if (_isLoading) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: Colors.brown),
        ],
      ],
    );
  }

  Widget _buildLoginView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    setState(() => _currentMode = AuthMode.welcome),
                icon: const Icon(Icons.arrow_back, color: Colors.brown),
              ),
              const Expanded(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),

          const SizedBox(height: 20),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: AuthService.validateEmail,
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: AuthService.validatePassword,
          ),

          const SizedBox(height: 24),

          // Login button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4BE0A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login', style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 16),

          // Create account footer
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentMode = AuthMode.register),
              child: const Text(
                'Don\'t have an account? Create one',
                style: TextStyle(color: Colors.brown),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    setState(() => _currentMode = AuthMode.welcome),
                icon: const Icon(Icons.arrow_back, color: Colors.brown),
              ),
              const Expanded(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 20),

          // Username field
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: AuthService.validateUsername,
          ),

          const SizedBox(height: 16),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: AuthService.validateEmail,
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: AuthService.validatePassword,
          ),

          const SizedBox(height: 16),

          // Confirm Password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) => AuthService.validatePasswordConfirmation(
              _passwordController.text,
              value,
            ),
          ),

          const SizedBox(height: 24),

          // Create Account button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4BE0A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Account',
                      style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 16),

          // Login footer
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentMode = AuthMode.login),
              child: const Text(
                'Already have an account? Login',
                style: TextStyle(color: Colors.brown),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String text, required VoidCallback? onTap}) {
    return SizedBox(
        width: double.infinity,
        child: Card(
          color: const Color(0xFFF4BE0A),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            highlightColor: const Color(0xFFCA8505),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ));
  }

  // ================== HANDLERS ==================

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    await _authService.loginAsGuest();

    if (mounted) {
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (mounted) {
        final needsVerification = result.message.contains('check your email');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: needsVerification ? Colors.orange : Colors.green,
            duration: Duration(seconds: needsVerification ? 8 : 3),
          ),
        );

        if (needsVerification) {
          setState(() => _currentMode = AuthMode.login);
        } else {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
