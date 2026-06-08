import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/colors.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _particleController;
  late AnimationController _scanController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scanAnimation;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _demoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    _particleController.dispose();
    _scanController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDemo() {
    final context = _demoKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildNavbar(context),
            _buildHero(context),
            _buildStatsBar(),
            _buildSystemFlow(),
            _buildWhyVisionPay(),
            _buildTechStack(),
            _buildDemoPreview(),
            _buildTeam(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.2))),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.visibility, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VisionPay',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text('AI Grocery Billing',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: AppColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('System Online',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Staff Login',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: 480,
        width: double.infinity,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _heroController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.95),
                        Color.lerp(
                          const Color(0xFF0F766E),
                          const Color(0xFF134E4A),
                          _heroController.value,
                        )!,
                        const Color(0xFF042F2E),
                      ],
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(_particleController.value),
                  size: Size.infinite,
                );
              },
            ),
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanAnimation.value * 480,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.gold.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            CustomPaint(
              painter: _GridPainter(),
              size: Size.infinite,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_outlined,
                            color: AppColors.gold, size: 14),
                        const SizedBox(width: 6),
                        Text('Final Year Project — KICSIT Batch 2022-2026',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('VisionPay',
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Text('AI-Powered Grocery\nBilling System',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Eliminate barcodes with computer vision.\nAI detects products & generates bills instantly.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen())),
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('Get Started'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _scrollToDemo,
                        icon: Icon(Icons.play_circle_outline,
                            size: 16, color: Colors.white.withOpacity(0.9)),
                        label: Text('Watch Demo',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.4)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF0D5C56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('50+', 'Product\nClasses', Icons.category_outlined),
          _vDivider(),
          _statItem('99.5%', 'Best\nAccuracy', Icons.analytics_outlined),
          _vDivider(),
          _statItem('<1s', 'Detection\nSpeed', Icons.speed_outlined),
          _vDivider(),
          _statItem('~30s', 'Full\nCheckout', Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(height: 6),
        Text(val,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style:
                TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.75)),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 50, color: Colors.white.withOpacity(0.15));

  Widget _buildSystemFlow() {
    final steps = [
      {
        'icon': Icons.camera_alt_outlined,
        'title': 'Capture',
        'desc': 'Camera captures products',
        'color': AppColors.primary
      },
      {
        'icon': Icons.psychology_outlined,
        'title': 'AI Detect',
        'desc': 'YOLOv8 identifies items',
        'color': AppColors.accent
      },
      {
        'icon': Icons.device_hub_outlined,
        'title': 'Decide',
        'desc': 'Weight or fixed price?',
        'color': AppColors.gold
      },
      {
        'icon': Icons.scale_outlined,
        'title': 'Weigh',
        'desc': 'Load cell measures weight',
        'color': const Color(0xFF7C3AED)
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Cart',
        'desc': 'Products added to cart',
        'color': AppColors.primary
      },
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'Bill',
        'desc': 'Digital receipt generated',
        'color': AppColors.success
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          _sectionHeader(
              'System Workflow', 'How VisionPay processes your checkout'),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: steps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                return Row(
                  children: [
                    _flowCard(step, i + 1),
                    if (i < steps.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.textSecondary.withOpacity(0.4)),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowCard(Map<String, dynamic> step, int num) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (step['color'] as Color).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: (step['color'] as Color).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (step['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(step['icon'] as IconData,
                color: step['color'] as Color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(step['title'] as String,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(step['desc'] as String,
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSecondary, height: 1.3),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: (step['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$num',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: step['color'] as Color)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Why VisionPay ─────────────────────────────────────────────────────────
  Widget _buildWhyVisionPay() {
    final reasons = [
      {
        'icon': Icons.qr_code_scanner_outlined,
        'title': 'No Barcodes Needed',
        'color': AppColors.primary
      },
      {
        'icon': Icons.flash_on_outlined,
        'title': 'Lightning Fast Checkout',
        'color': AppColors.gold
      },
      {
        'icon': Icons.scale_outlined,
        'title': 'Smart Weight Detection',
        'color': const Color(0xFF7C3AED)
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Live Inventory Management',
        'color': AppColors.accent
      },
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'Instant Digital Receipts',
        'color': AppColors.success
      },
      {
        'icon': Icons.devices_outlined,
        'title': 'Cross-Platform Support',
        'color': const Color(0xFFEF4444)
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          _sectionHeader('Why VisionPay?', 'The smarter way to checkout'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: reasons.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (r['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(r['icon'] as IconData,
                              color: r['color'] as Color, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Text(r['title'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const Spacer(),
                        Icon(Icons.check_circle,
                            color: (r['color'] as Color).withOpacity(0.7),
                            size: 18),
                      ],
                    ),
                    if (i < reasons.length - 1)
                      Divider(
                          height: 20, color: AppColors.border.withOpacity(0.2)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tech Stack ────────────────────────────────────────────────────────────
  Widget _buildTechStack() {
    final techs = [
      {
        'name': 'Flutter',
        'desc': 'Cross-Platform UI',
        'color': const Color(0xFF54C5F8),
        'icon': Icons.phone_android_outlined
      },
      {
        'name': 'Python',
        'desc': 'Backend & AI',
        'color': const Color(0xFF3776AB),
        'icon': Icons.code_outlined
      },
      {
        'name': 'YOLOv8',
        'desc': 'Object Detection',
        'color': AppColors.primary,
        'icon': Icons.visibility_outlined
      },
      {
        'name': 'SQLite',
        'desc': 'Database',
        'color': const Color(0xFF003B57),
        'icon': Icons.storage_outlined
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          _sectionHeader('Built With', 'Technology stack'),
          const SizedBox(height: 20),
          Row(
            children: techs
                .map((t) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: (t['color'] as Color).withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                                color: (t['color'] as Color).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (t['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(t['icon'] as IconData,
                                  color: t['color'] as Color, size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(t['name'] as String,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(t['desc'] as String,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Demo Preview ──────────────────────────────────────────────────────────
  Widget _buildDemoPreview() {
    return Padding(
      key: _demoKey,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          _sectionHeader('Live Demo Preview', 'See VisionPay in action'),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              children: [
                // Window bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.border.withOpacity(0.2))),
                  ),
                  child: Row(
                    children: [
                      _dot(const Color(0xFFFF5F57)),
                      const SizedBox(width: 6),
                      _dot(const Color(0xFFFFBD2E)),
                      const SizedBox(width: 6),
                      _dot(const Color(0xFF28C840)),
                      const SizedBox(width: 12),
                      Text('VisionPay — Cashier Dashboard',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Detection results
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF4ADE80),
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text('AI Detection Active',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('4 detected',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _demoProduct('🍅', 'Tomato', 'Weight-based',
                                '0.5kg × Rs 100', 'Rs 50', AppColors.gold),
                            _demoProduct('🧅', 'Onion', 'Weight-based',
                                '1.0kg × Rs 80', 'Rs 80', AppColors.gold),
                            _demoProduct('🍋', 'Lemon', 'Weight-based',
                                '0.3kg × Rs 200', 'Rs 60', AppColors.gold),
                            _demoProduct(
                                '🍟',
                                'Lays French Cheese',
                                'Fixed price',
                                '1 piece',
                                'Rs 20',
                                AppColors.primary),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Bill summary
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              const Color(0xFF0D5C56)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bill Generated ✓',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text('4 items • VP-20260524',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11)),
                              ],
                            ),
                            Text('Rs 210',
                                style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _demoProduct(String emoji, String name, String type, String detail,
      String price, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(detail,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(price,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  // ── Team ──────────────────────────────────────────────────────────────────
  Widget _buildTeam() {
    final members = [
      {'name': 'Naveed Hayat', 'initial': 'N', 'color': AppColors.primary},
      {'name': 'Nimrah Khan', 'initial': 'N', 'color': AppColors.accent},
      {'name': 'Mehak Razzaq', 'initial': 'M', 'color': AppColors.gold},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          _sectionHeader('Project Team', 'Meet the developers'),
          const SizedBox(height: 20),
          Row(
            children: members
                .map((m) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: (m['color'] as Color).withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                                color: (m['color'] as Color).withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    m['color'] as Color,
                                    (m['color'] as Color).withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: (m['color'] as Color)
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: Center(
                                child: Text(m['initial'] as String,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(m['name'] as String,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (m['color'] as Color).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('FYP 2026',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: m['color'] as Color,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF042F2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.visibility, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('VisionPay',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text('AI Grocery Billing System',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'Cross-Platform Grocery Billing Application Using Artificial Intelligence',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                height: 1.5),
          ),
          const SizedBox(height: 8),
          Text('VisionPay © 2026 — Final Year Project — KICSIT',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ParticlePainter(this.progress)
      : particles = List.generate(20, (i) => _Particle(i));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x =
          (p.x * size.width + progress * p.speed * size.width) % size.width;
      final y = (p.y * size.height + progress * p.speed * 0.5 * size.height) %
          size.height;
      final paint = Paint()
        ..color = Colors.white.withOpacity(p.opacity * 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

class _Particle {
  final double x, y, speed, radius, opacity;
  _Particle(int seed)
      : x = (seed * 0.137) % 1.0,
        y = (seed * 0.271) % 1.0,
        speed = 0.1 + (seed * 0.037) % 0.3,
        radius = 1.5 + (seed * 0.13) % 3.0,
        opacity = 0.2 + (seed * 0.07) % 0.5;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
