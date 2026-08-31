import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/sigot_wordmark.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _loading = false;
  bool _showSlowMessage = false;
  Timer? _slowTimer;
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _slowTimer?.cancel();
    _drift.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _showSlowMessage = false;
    });

    _slowTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showSlowMessage = true);
    });

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_correoCtrl.text.trim(), _passCtrl.text);

    _slowTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _showSlowMessage = false;
    });

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Error al iniciar sesión'),
          backgroundColor: const Color(0xFFef4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppBrand.brand),
          child: Stack(
            children: [
              // Resplandores ambientales que se desplazan lentamente.
              AnimatedBuilder(
                animation: _drift,
                builder: (context, _) {
                  final d = (_drift.value - 0.5) * 2;
                  return Stack(
                    children: [
                      Positioned(
                          bottom: -120 + d * 18,
                          right: -90 - d * 14,
                          child: _glow(360, 0.30)),
                      Positioned(
                          top: -110 - d * 14,
                          left: -100 + d * 16,
                          child: _glow(300, 0.10)),
                    ],
                  );
                },
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) => Opacity(
                          opacity: t.clamp(0, 1),
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - t)),
                            child: child,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBrand(),
                            const SizedBox(height: 26),
                            _buildCard(),
                            const SizedBox(height: 20),
                            _buildFooterNote(),
                          ],
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

  Widget _buildBrand() => Column(
        children: [
          const SigotWordmark(fontSize: 30, letterSpacing: 7),
          const SizedBox(height: 12),
          Text(
            'Sistema de Gestión de Órdenes y Taller',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              fontSize: 13.5,
            ),
          ),
        ],
      );

  Widget _buildCard() => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                const TextSpan(
                  text: 'Bienvenido ',
                  children: [
                    TextSpan(
                      text: 'de nuevo',
                      style: TextStyle(color: AppBrand.green),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Ingresa tus credenciales para continuar',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              _AuthField(
                controller: _correoCtrl,
                label: 'Correo electrónico',
                hint: 'correo@empresa.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa tu correo' : null,
              ),
              const SizedBox(height: 16),
              _AuthField(
                controller: _passCtrl,
                label: 'Contraseña',
                hint: '••••••••',
                icon: Icons.lock_outlined,
                obscure: !_showPass,
                suffix: IconButton(
                  icon: Icon(
                    _showPass ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF9ca3af),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _showPass = !_showPass),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppBrand.green,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _loading ? _buildLoadingState() : _buildButton(),
            ],
          ),
        ),
      );

  Widget _buildButton() => _PressableScale(
        onTap: _submit,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: AppBrand.buttonEmerald,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16a34a).withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ingresar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      );

  Widget _buildLoadingState() => Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppBrand.buttonEmerald,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Iniciando sesión...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (_showSlowMessage) ...[
              const SizedBox(height: 4),
              Text(
                'Iniciando servidor, por favor espera...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildFooterNote() => Text.rich(
        const TextSpan(
          text: '¿Sin acceso? Solicita tus credenciales al ',
          children: [
            TextSpan(
              text: 'administrador del taller',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.50),
          fontSize: 12,
          height: 1.5,
        ),
      );

  Widget _glow(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppBrand.green.withValues(alpha: opacity),
              AppBrand.green.withValues(alpha: 0),
            ],
          ),
        ),
      );
}

/// Campo con foco interactivo: al enfocar, el borde y el icono pasan a verde y
/// aparece un halo suave (glow), con transición animada.
class _AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() {
      if (mounted) setState(() => _focused = _node.hasFocus);
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        _focused ? AppBrand.green : const Color(0xFF9ca3af);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            widget.label,
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: _focused ? 0.95 : 0.80),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.ease,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppBrand.green.withValues(alpha: 0.28),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _node,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscure,
            style: const TextStyle(color: Colors.white),
            cursorColor: AppBrand.green,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle:
                  TextStyle(color: Colors.white.withValues(alpha: 0.32)),
              prefixIcon: Icon(widget.icon, color: iconColor, size: 20),
              suffixIcon: widget.suffix,
              filled: true,
              fillColor: Colors.white.withValues(alpha: _focused ? 0.10 : 0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppBrand.green, width: 1.6),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFef4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFef4444)),
              ),
              errorStyle: const TextStyle(color: Color(0xFFfca5a5)),
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}

/// Envoltorio que reduce ligeramente la escala al presionar (feedback táctil).
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}
