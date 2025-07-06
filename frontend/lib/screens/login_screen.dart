import 'package:flutter/material.dart';
import 'package:frontend/screens/map_screen.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _eposta = '';
  String _sifre = '';
  String _errorMessage = '';
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        final user = await _authService.login(_eposta, _sifre);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Giriş yapılamadı: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text('Yeşil Yol', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 50),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                       if (value == null || !value.contains('@')) {
                        return 'Geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                    onSaved: (value) => _eposta = value!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Şifre boş olamaz' : null,
                    onSaved: (value) => _sifre = value!,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: _login,
                          child: const Text('Giriş Yap'),
                        ),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Hesabın yok mu? Kayıt Ol'),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                         textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
