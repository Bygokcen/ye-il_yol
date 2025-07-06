import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _ad = '';
  String _soyad = '';
  String _eposta = '';
  String _sifre = '';
  String _errorMessage = '';
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        final adSoyad = '$_ad $_soyad'.trim();
        await _authService.register(adSoyad, _eposta, _sifre);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt başarılı! Lütfen giriş yapın.')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Kayıt başarısız: ${e.toString()}';
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
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ad', border: OutlineInputBorder()),
                  validator: (value) => value!.trim().isEmpty ? 'Ad boş olamaz' : null,
                  onSaved: (value) => _ad = value!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Soyad', border: OutlineInputBorder()),
                  validator: (value) => value!.trim().isEmpty ? 'Soyad boş olamaz' : null,
                  onSaved: (value) => _soyad = value!,
                ),
                const SizedBox(height: 12),
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
                  validator: (value) => value!.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
                  onSaved: (value) => _sifre = value!,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _register,
                        child: const Text('Kayıt Ol'),
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
    );
  }
}
