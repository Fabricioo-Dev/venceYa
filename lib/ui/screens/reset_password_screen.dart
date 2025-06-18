// lib/ui/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/core/theme.dart'; // Importar el tema

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  /// Envía un correo de restablecimiento de contraseña al email proporcionado.
  Future<void> _sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });
      try {
        await context
            .read<AuthService>()
            .sendPasswordResetEmail(email: _emailController.text.trim());

        setState(() {
          _successMessage =
              'Se ha enviado un correo electrónico para restablecer tu contraseña. Revisa tu bandeja de entrada.';
        });
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No existe un usuario con este correo electrónico.';
        } else {
          message =
              e.message ?? 'Error desconocido al restablecer la contraseña.';
        }
        setState(() {
          _errorMessage = "Error: $message";
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Error inesperado: ${e.toString()}";
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
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ingresa tu correo electrónico para recibir un enlace de restablecimiento.',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: AppTheme.textMedium),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    hintText: 'Ingrese su Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo electrónico';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: AppTheme.categoryRed, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(
                          color: AppTheme.categoryGreen, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _sendPasswordResetEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Enviar Enlace de Restablecimiento',
                            style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
