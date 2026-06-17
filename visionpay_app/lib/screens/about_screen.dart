import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'About VisionPay',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSystemFlow(),
            _buildWhyVisionPay(),
            _buildTechStack(),
            _buildDemoPreview(),
            _buildTeam(),
            _buildSupervisors(),
            _buildInstitute(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  // ── System Workflow ────────────────────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
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
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(step['desc'] as String,
              style: const TextStyle(
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

  // ── Why VisionPay ──────────────────────────────────────────────────────────
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
                            style: const TextStyle(
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

  // ── Tech Stack ─────────────────────────────────────────────────────────────
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
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(t['desc'] as String,
                                style: const TextStyle(
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

  // ── Demo Preview ───────────────────────────────────────────────────────────
  Widget _buildDemoPreview() {
    return Padding(
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
                      const Text('VisionPay — Cashier Dashboard',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                                // Animated scan dot
                                AnimatedBuilder(
                                  animation: _scanAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Color.lerp(
                                          const Color(0xFF4ADE80),
                                          const Color(0xFF22C55E),
                                          _scanAnimation.value,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                const Text('AI Detection Active',
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
                                  child: const Text('4 detected',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _demoProduct('🍅', 'Tomato', '0.5kg × Rs 100',
                                'Rs 50', AppColors.gold),
                            _demoProduct('🧅', 'Onion', '1.0kg × Rs 80',
                                'Rs 80', AppColors.gold),
                            _demoProduct('🍋', 'Lemon', '0.3kg × Rs 200',
                                'Rs 60', AppColors.gold),
                            _demoProduct('🍟', 'Lays French Cheese', '1 piece',
                                'Rs 20', AppColors.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF0D5C56)],
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
                            const Text('Rs 210',
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

  Widget _demoProduct(
      String emoji, String name, String detail, String price, Color color) {
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
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(detail,
                    style: const TextStyle(
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

  // ── Project Team ───────────────────────────────────────────────────────────
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
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                                textAlign: TextAlign.center),
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

  // ── Supervisors ────────────────────────────────────────────────────────────
  Widget _buildSupervisors() {
    final supervisors = [
      {
        'name': 'Dr. Sehrish Khan Tayyaba',
        'role': 'Supervisor',
        'initial': 'S',
        'color': AppColors.primary,
      },
      {
        'name': 'Dr. Altaf Hussain',
        'role': 'Co-Supervisor',
        'initial': 'A',
        'color': AppColors.accent,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          _sectionHeader('Supervised By', 'Faculty guidance'),
          const SizedBox(height: 20),
          Row(
            children: supervisors
                .map((s) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: (s['color'] as Color).withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                                color: (s['color'] as Color).withOpacity(0.1),
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
                                    s['color'] as Color,
                                    (s['color'] as Color).withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(s['initial'] as String,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(s['name'] as String,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: (s['color'] as Color).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(s['role'] as String,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: s['color'] as Color,
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

  // ── Institute ──────────────────────────────────────────────────────────────
  Widget _buildInstitute() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF042F2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 16),
            const Text('KICSIT',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(height: 6),
            Text(
              'Khan Institute of Computer Science\nand Information Technologies',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.white.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text('Batch 2022 – 2026',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.75), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: const Text(
                'Final Year Project 2026',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
