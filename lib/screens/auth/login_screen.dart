import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand/phanukngan_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _form     = GlobalKey<FormState>();

  bool _loading    = false;
  bool _showPass   = false;
  bool _isRegister = false;
  String? _error;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // ==========================================
  // LOGIN
  // ==========================================
  Future<void> _login() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      await _supabase.auth.signInWithPassword(
        email:    _email.text.trim(),
        password: _password.text.trim(),
      );
      if (mounted) context.go('/home');

    } on AuthException catch (e) {
      setState(() => _error = _errorLao(e.message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ==========================================
  // REGISTER
  // ==========================================
  Future<void> _register() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      final res = await _supabase.auth.signUp(
        email:    _email.text.trim(),
        password: _password.text.trim(),
      );

      // ສ້າງ Profile
      if (res.user != null) {
        await _supabase.from('profiles').upsert({
          'id':         res.user!.id,
          'brand_name': 'PHANUKNGAN',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ສ້າງບັນຊີສຳເລັດ! ກວດ Email ຂອງທ່ານເພື່ອຢືນຢັນ',
              style: AppTheme.laoText(size: 13, color: Colors.white),
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        setState(() => _isRegister = false);
      }
    } on AuthException catch (e) {
      setState(() => _error = _errorLao(e.message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorLao(String msg) {
    if (msg.contains('Invalid login')) return 'Email ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ';
    if (msg.contains('Email not confirmed')) return 'ກວດ Email ເພື່ອຢືນຢັນກ່ອນ';
    if (msg.contains('already registered')) return 'Email ນີ້ໃຊ້ແລ້ວ — ລອງ Login';
    if (msg.contains('Password should')) return 'ລະຫັດຜ່ານຕ້ອງຢ່າງໜ້ອຍ 6 ໂຕ';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhanuknganColors.navy,
      body: Stack(children: [
        // ---- Deco circles ----
        Positioned(top: -60, right: -60, child: Container(
          width: 220, height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white.withOpacity(0.07))),
        )),
        Positioned(bottom: 100, left: -50, child: Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PhanuknganColors.gold.withOpacity(0.07)),
        )),

        // ---- Content ----
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 40),

              // Logo
              PhanuknganLogo(variant: LogoVariant.splash, size: 90)
              .animate()
              .scale(begin: const Offset(0.5,0.5), duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

              const SizedBox(height: 48),

              // Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _form,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Title
                    Text(
                      _isRegister ? 'ສ້າງບັນຊີໃໝ່' : 'ເຂົ້າສູ່ລະບົບ',
                      style: AppTheme.laoDisplay(size: 20),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                    const SizedBox(height: 4),
                    Text(
                      _isRegister
                          ? 'ສ້າງ Account ເພື່ອໃຊ້ PHANUKNGAN'
                          : 'ຍິນດີຕ້ອນຮັບກັບຄືນ, ເຈົ້ານາຍ!',
                      style: AppTheme.laoText(size: 13, color: AppTheme.textSecondary),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 24),

                    // Error
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          border: Border.all(color: AppTheme.danger.withOpacity(0.3))),
                        child: Row(children: [
                          Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: AppTheme.laoText(size: 12, color: AppTheme.danger))),
                        ]),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email field
                    _FieldLabel('Email'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTheme.laoText(size: 14),
                      decoration: _inputDec('your@email.com', Icons.mail_outline_rounded),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'ໃສ່ Email ກ່ອນ';
                        if (!v.contains('@')) return 'Email ບໍ່ຖືກຮູບແບບ';
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // Password field
                    _FieldLabel('ລະຫັດຜ່ານ'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _password,
                      obscureText: !_showPass,
                      style: AppTheme.laoText(size: 14),
                      decoration: _inputDec('ໃສ່ລະຫັດຜ່ານ', Icons.lock_outline_rounded).copyWith(
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _showPass = !_showPass),
                          child: Icon(
                            _showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppTheme.textMuted, size: 20),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) return 'ລະຫັດຜ່ານຢ່າງໜ້ອຍ 6 ໂຕ';
                        return null;
                      },
                      onFieldSubmitted: (_) => _isRegister ? _register() : _login(),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 28),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : (_isRegister ? _register : _login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PhanuknganColors.navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                _isRegister ? 'ສ້າງບັນຊີ' : 'ເຂົ້າສູ່ລະບົບ',
                                style: AppTheme.laoText(size: 15, weight: FontWeight.w600, color: Colors.white)),
                      ),
                    ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms, begin: const Offset(0.95,0.95)),

                    const SizedBox(height: 20),

                    // Toggle login/register
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() { _isRegister = !_isRegister; _error = null; }),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: _isRegister ? 'ມີ Account ແລ້ວ? ' : 'ຍັງບໍ່ມີ Account? ',
                              style: AppTheme.laoText(size: 13, color: AppTheme.textSecondary)),
                            TextSpan(
                              text: _isRegister ? 'ເຂົ້າສູ່ລະບົບ' : 'ສ້າງໃໝ່',
                              style: AppTheme.laoText(size: 13, color: PhanuknganColors.navy, weight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, duration: 500.ms, curve: AppTheme.easeOut),

              const SizedBox(height: 32),
              Text(
                'ຂໍ້ມູນຂອງທ່ານຖືກຮັກສາໄວ້ ຢ່າງປອດໄພ ດ້ວຍ Supabase',
                style: AppTheme.laoCaption(color: Colors.white.withOpacity(0.4)),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: AppTheme.laoCaption(),
    prefixIcon: Icon(icon, size: 18, color: AppTheme.textMuted),
    filled: true,
    fillColor: AppTheme.surfaceAlt,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      borderSide: BorderSide(color: AppTheme.border)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      borderSide: BorderSide(color: AppTheme.border)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      borderSide: const BorderSide(color: PhanuknganColors.navy, width: 1.5)),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      borderSide: BorderSide(color: AppTheme.danger)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

// ---- Field Label ----
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTheme.laoText(size: 12, weight: FontWeight.w500, color: AppTheme.textSecondary),
  );
}
