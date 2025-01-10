import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/screens/onboarding_screen.dart';
import 'package:movely/screens/home_screen.dart';
import 'package:movely/services/activity_service.dart';

class AuthScreen extends StatefulWidget {
  final ActivityService activityService;

  const AuthScreen({Key? key, required this.activityService}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isNewAccount = true;
  final _otpController = TextEditingController();
  bool _showOtpField = false;

  void _showEmailInput() {
    setState(() {
      _emailController.clear();
      _otpController.clear();
      _showOtpField = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_showOtpField) {
      await _verifyOtp();
    } else {
      await _requestOtp();
    }
  }

  Future<void> _requestOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text,
      );
      setState(() {
        _showOtpField = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check your email for the verification code!')),
      );
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

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: _emailController.text,
        token: _otpController.text,
        type: OtpType.magiclink,
      );
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
      body: Container(
        color: const Color(0xFF1E1E1E),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Movely',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                if (!_showOtpField && (_emailController.text.isEmpty)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isNewAccount = true;
                            });
                            _showEmailInput();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E1E1E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            side: BorderSide(
                              color: _isNewAccount ? Colors.purple.shade400 : Colors.grey,
                            ),
                          ),
                          child: const Text('Create Account'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isNewAccount = false;
                            });
                            _showEmailInput();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E1E1E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            side: BorderSide(
                              color: !_isNewAccount ? Colors.purple.shade400 : Colors.grey,
                            ),
                          ),
                          child: const Text('I Have an Account'),
                        ),
                      ],
                    ),
                  ),
                ] else if (!_showOtpField) ...[
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.purple.shade400),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Send Code'),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      hintText: 'Enter verification code',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_showOtpField ? 'Verify Code' : 'Send Code'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF1E1E1E),
                  ),
                ),
                if (_showOtpField) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : () {
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
      ),
    );
  }
}
