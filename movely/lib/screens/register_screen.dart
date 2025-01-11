import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/services/activity_service.dart';
import 'package:movely/screens/onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  final ActivityService activityService;

  const RegisterScreen({Key? key, required this.activityService})
      : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _canResendCode = true;
  int _resendTimer = 30;
  Timer? _timer;

  Future<void> _register() async {
    if (_showOtpField) {
      await _verifyOtp();
    } else {
      await _requestOtp();
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResendCode = false;
      _resendTimer = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResendCode = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists in auth.users
      final List<dynamic> existingUsers = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', _emailController.text)
          .limit(1);

      if (existingUsers.isNotEmpty) {
        throw Exception('Account already exists');
      }

      // Check if username exists
      final usernameExists = await Supabase.instance.client
          .from('users')
          .select()
          .eq('username', _emailController.text.split('@')[0])
          .single();

      if (usernameExists != null) {
        throw Exception('Username already taken');
      }

      await Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text,
      );
      _startResendTimer();
      setState(() {
        _showOtpField = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Check your email for the verification code!')),
      );
    } catch (error) {
      String errorMessage = 'An error occurred. Please try again later.';
      if (error.toString().contains('Account already exists')) {
        errorMessage = 'An account with this email already exists';
      } else if (error.toString().contains('Username already taken')) {
        errorMessage = 'This username is already taken';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response =
          await Supabase.instance.client.auth.verifyOTP(
        email: _emailController.text,
        token: _otpController.text,
        type: OtpType.signup,
      );

      if (response.session == null) {
        throw Exception('Verification failed');
      }

      // Wait a moment for the session to be properly established
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to onboarding after successful verification
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(
              activityService: widget.activityService,
            ),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_showOtpField) ...[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Continue'),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  maxLength: 6,
                  onChanged: (value) {
                    // Only allow numbers
                    if (value.isNotEmpty &&
                        !RegExp(r'^[0-9]*$').hasMatch(value)) {
                      _otpController.text =
                          value.replaceAll(RegExp(r'[^0-9]'), '');
                      _otpController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _otpController.text.length));
                    }
                    if (value.length == 6) {
                      _register();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit verification code',
                    helperText: '6 numbers required',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Verify Code'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _showOtpField = false;
                            _otpController.clear();
                          });
                        },
                  child: const Text('Use different email'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
