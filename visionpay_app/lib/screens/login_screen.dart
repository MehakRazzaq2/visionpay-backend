import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'manager/manager_dashboard.dart';
import 'cashier/cashier_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  final Map<String, Map<String, String>> _users = {
    'manager': {'password': 'manager123', 'role': 'manager', 'name': 'Store Manager'},
    'cashier': {'password': 'cashier123', 'role': 'cashier', 'name': 'Cashier'},
  };

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnimation = CurvedAnimation(
        parent: _cardController, curve: Curves.easeOutBack);
    _cardController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (_users.containsKey(username) &&
        _users[username]!['password'] == password) {
      final role = _users[username]!['role']!;
      final name = _users[username]!['name']!;

      if (!mounted) return;

      if (role == 'manager') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ManagerDashboard(fullName: name),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CashierDashboard(fullName: name),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Layer 1: Deep teal background ──────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF021B19),
                      Color.lerp(
                        const Color(0xFF042F2E),
                        const Color(0xFF021B19),
                        _bgController.value,
                      )!,
                      const Color(0xFF042F2E),
                    ],
                  ),
                ),
              );
            },
          ),

          // Grid pattern
          CustomPaint(
            painter: _LoginGridPainter(),
            size: Size.infinite,
          ),

          // Particles
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                painter: _LoginParticlePainter(_bgController.value),
                size: Size.infinite,
              );
            },
          ),

          // ── Layer 2: Medium teal overlay panel ─────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F766E).withOpacity(0.6),
                    const Color(0xFF134E4A).withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: const Color(0xFF0D5C56).withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(16),
                child: ScaleTransition(
                  scale: _cardAnimation,

                  // ── Layer 3: White login card ───────────────────────
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF0F766E),
                                const Color(0xFF14B8A6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F766E).withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.visibility,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 14),
                        const Text('VisionPay',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF134E4A))),
                        const SizedBox(height: 4),
                        Text('Sign in to continue',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                        const SizedBox(height: 24),

                        // Username
                        _buildLabel('Username'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF134E4A)),
                          decoration: _inputDecoration(
                            hint: 'Enter username',
                            prefixIcon: Icons.person_outline,
                            suffix: PopupMenuButton<String>(
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFF0F766E)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              onSelected: (value) {
                                setState(() {
                                  _usernameController.text = value;
                                  _errorMessage = '';
                                });
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'manager',
                                  child: Row(
                                    children: [
                                      Icon(Icons.manage_accounts_outlined,
                                          color: const Color(0xFF0F766E),
                                          size: 18),
                                      const SizedBox(width: 10),
                                      const Text('manager',
                                          style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'cashier',
                                  child: Row(
                                    children: [
                                      Icon(Icons.point_of_sale_outlined,
                                          color: const Color(0xFF14B8A6),
                                          size: 18),
                                      const SizedBox(width: 10),
                                      const Text('cashier',
                                          style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF134E4A)),
                          decoration: _inputDecoration(
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          onFieldSubmitted: (_) => _login(),
                        ),

                        // Error
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade400, size: 15),
                                const SizedBox(width: 7),
                                Text(_errorMessage,
                                    style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Sign In',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('VisionPay © 2026',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Back Button ─────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF134E4A))),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(prefixIcon,
          color: const Color(0xFF0F766E), size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF0FDFA),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFF0F766E), width: 1.5),
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────
class _LoginParticlePainter extends CustomPainter {
  final double progress;
  _LoginParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 18; i++) {
      final x = (i * 0.137 * size.width +
              progress * 0.08 * size.width) %
          size.width;
      final y = (i * 0.271 * size.height +
              progress * 0.04 * size.height) %
          size.height;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.04 + (i % 4) * 0.02)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(_LoginParticlePainter old) => true;
}

class _LoginGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LoginGridPainter old) => false;
}