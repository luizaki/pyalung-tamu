import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:async';

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

  Timer? _usernameDebounce;
  Timer? _passwordDebounce;
  Timer? _confirmDebounce;
  String? _usernameError;
  String? _passwordError;
  String? _confirmError;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    _usernameDebounce?.cancel();
    _passwordDebounce?.cancel();
    _confirmDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final kb = mq.viewInsets.bottom;

    final dialogWidth = (size.width * 0.42).clamp(320.0, 520.0);

    final lift = kb.clamp(0.0, size.height * 0.45);

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: (size.width * 0.06).clamp(12.0, 48.0),
          vertical: 24,
        ),
        child: Stack(
          children: [
            AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: lift),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: dialogWidth,
                    maxHeight: size.height * 0.92,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xF9DD9A00),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xAD572100), width: 8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xAD572100).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight * 0.0,
                                  ),
                                  child: _buildCurrentView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 20),

          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: AuthService.validateEmail,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120,
                ),
              ),
              if (_emailError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _emailError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (v) {
              _passwordDebounce?.cancel();
              _passwordDebounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  _passwordError = AuthService.validatePassword(v);
                });
              });
            },
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              helperText: 'At least 6 characters',
              helperStyle: TextStyle(color: Colors.grey[700]),
              errorText: _passwordError,
            ),
            validator: AuthService.validatePassword,
            scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
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
            onChanged: (v) {
              _usernameDebounce?.cancel();
              _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  _usernameError = AuthService.validateUsername(v);
                });
              });
            },
            decoration: InputDecoration(
              labelText: 'Username',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              helperText: '3-20 chars • a-z A-Z 0-9 _ only',
              helperStyle: TextStyle(color: Colors.grey[700]),
              errorText: _usernameError,
            ),
            validator: AuthService.validateUsername,
            scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
          ),

          const SizedBox(height: 16),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: AuthService.validateEmail,
            scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            onChanged: (v) {
              _passwordDebounce?.cancel();
              _passwordDebounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  _passwordError = AuthService.validatePassword(v);
                  final ce = _liveConfirmError(_confirmPasswordController.text);
                  _confirmError = ce;
                });
              });
            },
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              helperText: 'At least 6 characters',
              helperStyle: TextStyle(color: Colors.grey[700]),
              errorText: _passwordError,
            ),
            validator: AuthService.validatePassword,
            scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
          ),

          const SizedBox(height: 16),

          // Confirm Password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            onChanged: (v) {
              _confirmDebounce?.cancel();
              _confirmDebounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  _confirmError = _liveConfirmError(v);
                });
              });
            },
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              helperText: 'At least 6 characters',
              helperStyle: TextStyle(color: Colors.grey[700]),
              errorText: _confirmError,
            ),
            validator: (value) => AuthService.validatePasswordConfirmation(
              _passwordController.text,
              value,
            ),
            scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
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

  // ================== REUSABLE CARD BUILDER ==================
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
      ),
    );
  }

  // ================== HANDLERS ==================

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    await _authService.loginAsGuest();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(true);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

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
        Navigator.of(context, rootNavigator: true).pop(true);
      }
    } else {
      if (mounted) {
        if (result.message.contains('Invalid email') ||
            result.message.contains('does not exist')) {
          setState(() {
            _emailError = 'This email does not exist in our records';
          });
        } else {
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
          Navigator.of(context, rootNavigator: true).pop(true);
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

  String? _liveConfirmError(String v) {
    final base = AuthService.validatePassword(v);
    if (base != null) return base;
    if (_passwordController.text != v) return 'Passwords do not match';
    return null;
  }
}
