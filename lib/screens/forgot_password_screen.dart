import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _service = AuthService();
  bool _loading = false;
  bool _sent = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _service.recuperarPassword(_correoCtrl.text.trim());
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
        _startCountdown();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Recuperar contraseña')),
        body: SafeArea(
          child: _sent ? _buildConfirmation() : _buildForm(),
        ),
      );

  Widget _buildForm() => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.email_outlined,
                size: 72, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Ingresa tu correo registrado y te enviaremos un enlace para restablecer tu contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: AppColors.textPrimary, height: 1.5),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _correoCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa tu correo' : null,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enviar enlace'),
            ),
          ],
        ),
      );

  Widget _buildConfirmation() => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Revisa tu correo',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Si el correo está registrado recibirás un enlace en los próximos minutos. Expira en 15 minutos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿No lo ves? Revisa spam.',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            if (_countdown > 0)
              Text(
                'Reenviar en $_countdown s',
                style: const TextStyle(color: AppColors.textMuted),
              )
            else
              TextButton(
                onPressed: () {
                  setState(() => _sent = false);
                },
                child: const Text('Reenviar enlace'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
}
