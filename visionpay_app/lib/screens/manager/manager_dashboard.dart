import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../theme/colors.dart';
import '../../config/app_config.dart';
import '../login_screen.dart';

class ManagerDashboard extends StatefulWidget {
  final String fullName;
  const ManagerDashboard({super.key, required this.fullName});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {};
  List _products = [];
  List _transactions = [];
  List _lowStock = [];
  bool _isLoading = true;
  final String _apiBase = AppConfig.apiBase;

  final List<Map<String, dynamic>> _staff = [
    {
      'name': 'Store Manager',
      'role': 'Manager',
      'status': 'Online',
      'time': '09:00 AM'
    },
    {
      'name': 'Cashier One',
      'role': 'Cashier',
      'status': 'Online',
      'time': '09:15 AM'
    },
    {
      'name': 'Cashier Two',
      'role': 'Cashier',
      'status': 'Online',
      'time': '09:15 AM'
    },
  ];

  // Fake transactions for demo
  final List<Map<String, dynamic>> _fakeTransactions = [
    {
      'bill_id': 'VP-20260524001',
      'cashier': 'Cashier One',
      'total': 450.0,
      'items_count': 5,
      'timestamp': '25-05-2026 09:30:00',
      'payment_method': 'Cash',
      'status': 'Paid',
      'items': 'Tomato, Onion, Lays, CocoMo, Banana'
    },
    {
      'bill_id': 'VP-20260524002',
      'cashier': 'Cashier Two',
      'total': 280.0,
      'items_count': 3,
      'timestamp': '25-05-2026 10:15:00',
      'payment_method': 'JazzCash',
      'status': 'Paid',
      'items': 'Apple, Garlic, Candi Biscuit'
    },
    {
      'bill_id': 'VP-20260524003',
      'cashier': 'Cashier One',
      'total': 620.0,
      'items_count': 7,
      'timestamp': '25-05-2026 11:00:00',
      'payment_method': 'Card',
      'status': 'Paid',
      'items': 'Cucumber, Eggplant, Capsicum, Lemon, CocoMo, Lays, Bitter Gourd'
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await http.get(Uri.parse('$_apiBase/stats'));
      final productsRes = await http.get(Uri.parse('$_apiBase/products'));
      final txRes = await http.get(Uri.parse('$_apiBase/transactions'));
      final lowStockRes = await http.get(Uri.parse('$_apiBase/low-stock'));

      setState(() {
        _stats = json.decode(statsRes.body);
        _products = json.decode(productsRes.body)['products'] ?? [];
        _transactions = json.decode(txRes.body)['transactions'] ?? [];
        _lowStock = json.decode(lowStockRes.body)['low_stock'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Connection error — check server!', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _addProduct(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$_apiBase/product/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (res.statusCode == 200) {
        _showSnack('Product added successfully!');
        _fetchData();
      }
    } catch (e) {
      _showSnack('Failed to add product', isError: true);
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      final res = await http.delete(Uri.parse('$_apiBase/product/delete/$id'));
      if (res.statusCode == 200) {
        _showSnack('Product deleted!');
        _fetchData();
      }
    } catch (e) {
      _showSnack('Failed to delete product', isError: true);
    }
  }

  Future<void> _updateStock(int id, int qty) async {
    try {
      final res = await http.put(
        Uri.parse('$_apiBase/product/stock/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'quantity': qty}),
      );
      if (res.statusCode == 200) {
        _showSnack('Stock updated!');
        _fetchData();
      }
    } catch (e) {
      _showSnack('Failed to update stock', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.visibility, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VisionPay',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text('Manager Dashboard',
                  style:
                      TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
      actions: [
        if (_lowStock.isNotEmpty)
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.primary),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${_lowStock.length}',
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: _showLowStockDialog,
          ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          onPressed: _fetchData,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.inventory_2_outlined),
                if (_lowStock.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Staff',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return _buildProducts();
      case 2:
        return _buildTransactions();
      case 3:
        return _buildStaff();
      case 4:
        return _buildProfile();
      default:
        return _buildHome();
    }
  }

  // ── HOME ──────────────────────────────────────────────────────────────────
  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome back,',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(widget.fullName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Online',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Low stock banner
            if (_lowStock.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          '${_lowStock.length} product(s) need restocking',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: const Text('View',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            // 4 Clickable stat cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: [
                _clickableStatCard(
                  title: "Today's Revenue",
                  value:
                      'Rs ${(_stats['today_revenue'] ?? 0).toStringAsFixed(0)}',
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xFF0F766E),
                  onTap: _showRevenueDetails,
                ),
                _clickableStatCard(
                  title: "Today's Sales",
                  value: '${_stats['today_transactions'] ?? 0} txn',
                  icon: Icons.receipt_outlined,
                  color: const Color.fromARGB(255, 220, 158, 114),
                  onTap: _showSalesDetails,
                ),
                _clickableStatCard(
                  title: 'Monthly Revenue',
                  value:
                      'Rs ${(_stats['monthly_revenue'] ?? 0).toStringAsFixed(0)}',
                  icon: Icons.calendar_month_outlined,
                  color: const Color(0xFF0D9488),
                  onTap: _showMonthlyDetails,
                ),
                _clickableStatCard(
                  title: 'Low Stock',
                  value: '${_stats['low_stock_count'] ?? 0} items',
                  icon: Icons.warning_amber_outlined,
                  color: const Color.fromARGB(255, 210, 136, 97),
                  onTap: _showLowStockDetails,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent transactions — only 3
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 2),
                  child: const Text('See All',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._getAllTransactions().take(3).map((tx) => _txCard(tx)),
          ],
        ),
      ),
    );
  }

  Widget _clickableStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(title,
                      style: TextStyle(
                          fontSize: 9, color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.7), size: 14),
          ],
        ),
      ),
    );
  }

  // ── PRODUCTS ──────────────────────────────────────────────────────────────
  Widget _buildProducts() {
    final weightBased =
        _products.where((p) => p['weight_based'] == true).toList();
    final packed = _products.where((p) => p['weight_based'] == false).toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Products',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                ElevatedButton.icon(
                  onPressed: _showAddProductDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Product overview cards at top
            Row(
              children: [
                Expanded(
                    child: _miniCard('Total', '${_products.length}',
                        Icons.category_outlined, AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(
                    child: _miniCard('Packed', '${packed.length}',
                        Icons.label_outline, const Color(0xFF0D9488))),
                const SizedBox(width: 8),
                Expanded(
                    child: _miniCard('Weight', '${weightBased.length}',
                        Icons.scale_outlined, const Color(0xFFF97316))),
                const SizedBox(width: 8),
                Expanded(
                    child: _miniCard('Alerts', '${_lowStock.length}',
                        Icons.warning_outlined, AppColors.error)),
              ],
            ),
            const SizedBox(height: 16),

            // Needs restocking
            if (_lowStock.isNotEmpty) ...[
              _sectionHeader(
                  '⚠️ Needs Restocking (${_lowStock.length})', AppColors.error),
              const SizedBox(height: 8),
              ..._lowStock.map((p) => _productCard(p, isAlert: true)),
              const SizedBox(height: 14),
            ],

            // Packed
            _sectionHeader(
                '📦 Packed Products (${packed.length})', AppColors.primary),
            const SizedBox(height: 8),
            ...packed.map((p) => _productCard(p)),
            const SizedBox(height: 14),

            // Weight based
            _sectionHeader('⚖️ Weight Based (${weightBased.length})',
                const Color(0xFFF97316)),
            const SizedBox(height: 8),
            ...weightBased.map((p) => _productCard(p)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(title,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _productCard(dynamic p, {bool isAlert = false}) {
    final isMap = p is Map;
    final id = isMap ? p['id'] : p[0];
    final name = isMap ? p['name'] : p[1];
    final isWeight = isMap ? p['weight_based'] : p[5] == 1;
    final price = isWeight
        ? 'Rs ${isMap ? p['price_per_kg'] : p[6]}/kg'
        : 'Rs ${isMap ? p['price_per_unit'] : p[4]}/piece';
    final qty = isWeight ? '∞' : '${isMap ? p['quantity'] : p[9]}';
    final remark = isMap ? (p['stock_remark'] ?? '') : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isAlert
                ? AppColors.error.withOpacity(0.3)
                : AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isWeight
                  ? const Color(0xFFF97316).withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isWeight ? '⚖' : '📦',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 13)),
                Text(
                  isWeight ? 'Available • Sold by kg' : '$price • Stock: $qty units',
                  style: TextStyle(
                      fontSize: 11,
                      color:
                          isAlert ? AppColors.error : AppColors.textSecondary),
                ),
                if (remark.isNotEmpty)
                  Text(remark,
                      style: TextStyle(
                          fontSize: 10,
                          color:
                              isAlert ? AppColors.error : AppColors.success)),
              ],
            ),
          ),
          Row(
            children: [
              if (!isWeight)
                GestureDetector(
                  onTap: () => _showUpdateStockDialog(id, name, qty),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_circle_outline,
                        color: AppColors.primary, size: 18),
                  ),
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _confirmDelete(id, name),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TRANSACTIONS ──────────────────────────────────────────────────────────
  Widget _buildTransactions() {
    final allTx = _getAllTransactions();
    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Transactions (${allTx.length})',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Tap any transaction for details',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ...allTx.map((tx) => _txCardDetailed(tx)),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllTransactions() {
    final realTx = _transactions.map((tx) {
      final isMap = tx is Map;
      return {
        'bill_id': isMap ? tx['bill_id'] : tx[1],
        'cashier': isMap ? tx['cashier'] : tx[2],
        'total': isMap ? tx['total'] : tx[3],
        'items_count': isMap ? tx['items_count'] : tx[4],
        'timestamp': isMap ? tx['timestamp'] : tx[5],
        'payment_method': isMap ? (tx['payment_method'] ?? 'Cash') : 'Cash',
        'status': isMap ? (tx['status'] ?? 'Paid') : 'Paid',
        'items': isMap ? (tx['items_json'] ?? '') : '',
      };
    }).toList();

    // Real transactions first (newest first from backend ORDER BY id DESC), fakes appended for demo
    return [...realTx, ..._fakeTransactions];
  }

  Widget _txCard(Map<String, dynamic> tx) {
    final billId = tx['bill_id']?.toString() ?? 'Transaction';
    final items = tx['items_count'] ?? 0;
    final time = tx['timestamp']?.toString() ?? '';
    final total = (tx['total'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(billId,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 12)),
                Text('$items items • $time',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('Rs ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _txCardDetailed(Map<String, dynamic> tx) {
    return GestureDetector(
      onTap: () => _showTransactionDetails(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent]),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.receipt_long, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx['bill_id'] ?? 'Transaction',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                      '${tx['items_count']} items • Cashier: ${tx['cashier'] ?? 'N/A'}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  Text(tx['timestamp'] ?? '',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rs ${(tx['total'] ?? 0).toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 15)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Paid',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Transaction Details',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Bill ID', tx['bill_id'] ?? 'N/A', AppColors.primary),
            _detailRow('Cashier', tx['cashier'] ?? 'N/A', AppColors.accent),
            _detailRow('Items Count', '${tx['items_count']} products',
                AppColors.textPrimary),
            _detailRow('Payment Method',
                tx['payment_method'] ?? tx['payment'] ?? 'Cash',
                AppColors.success),
            _detailRow('Status',
                '✅ ${tx['status'] ?? (tx['paid'] == true ? 'Paid' : 'Unpaid')}',
                AppColors.success),
            _detailRow(
                'Date & Time', tx['timestamp'] ?? 'N/A', AppColors.textSecondary),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text('Rs ${(tx['total'] ?? 0).toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── STAFF ─────────────────────────────────────────────────────────────────
  Widget _buildStaff() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff Overview',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Active staff members today',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _miniCard('Total Staff', '${_staff.length}',
                      Icons.people_outline, AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _miniCard(
                      'Online Now',
                      '${_staff.where((s) => s['status'] == 'Online').length}',
                      Icons.circle,
                      AppColors.success)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Staff Members',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._staff.map((s) => _staffCard(s)),
          const SizedBox(height: 20),
          const Text("Today's Activity",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              children: [
                _activityRow(Icons.login, 'Cashier One logged in', '09:15 AM',
                    AppColors.success),
                const Divider(height: 20),
                _activityRow(Icons.login, 'Cashier Two logged in', '09:20 AM',
                    AppColors.success),
                const Divider(height: 20),
                _activityRow(
                    Icons.receipt_long,
                    'Transactions today',
                    '${_stats['today_transactions'] ?? 0} sales',
                    AppColors.primary),
                const Divider(height: 20),
                _activityRow(
                    Icons.monetization_on,
                    'Revenue today',
                    'Rs ${(_stats['today_revenue'] ?? 0).toStringAsFixed(0)}',
                    AppColors.gold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffCard(Map<String, dynamic> s) {
    final isOnline = s['status'] == 'Online';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient:
                  LinearGradient(colors: [AppColors.primary, AppColors.accent]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(s['name'][0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14)),
                Text(s['role'],
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.success.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isOnline
                          ? AppColors.success.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: isOnline ? AppColors.success : Colors.grey,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(s['status'],
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOnline ? AppColors.success : Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('Since ${s['time']}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityRow(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary))),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ── PROFILE ───────────────────────────────────────────────────────────────
  Widget _buildProfile() {
    bool aboutExpanded = false;
    return StatefulBuilder(
      builder: (context, setS) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0D5C56)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(widget.fullName[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Store Manager',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick stats
            Row(
              children: [
                Expanded(
                    child: _miniCard(
                        "Today's Sales",
                        '${_stats['today_transactions'] ?? 0}',
                        Icons.receipt_outlined,
                        AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniCard('Products', '${_products.length}',
                        Icons.inventory_outlined, AppColors.accent)),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniCard('Alerts', '${_lowStock.length}',
                        Icons.warning_outlined, AppColors.error)),
              ],
            ),
            const SizedBox(height: 20),

            // Store info — non-functional, display only
            _profileOption(Icons.store_outlined, 'Store Information',
                'VisionPay Grocery Store — KICSIT 2026', AppColors.primary,
                onTap: null),

            // About App — expandable
            GestureDetector(
              onTap: () => setS(() => aboutExpanded = !aboutExpanded),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.info_outline,
                              color: AppColors.textSecondary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('About App',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      fontSize: 13)),
                              Text('Tap to expand',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Icon(
                            aboutExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 20),
                      ],
                    ),
                    if (aboutExpanded) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _aboutRow('App Name', 'VisionPay'),
                      _aboutRow('Version', 'v1.0.0'),
                      _aboutRow('Project', 'Final Year Project'),
                      _aboutRow('Institute', 'KICSIT'),
                      _aboutRow('Year', '2026'),
                      _aboutRow('Model', 'YOLOv8n — 53 Classes'),
                      _aboutRow('Backend', 'FastAPI + SQLite'),
                      _aboutRow('Frontend', 'Flutter'),
                      _aboutRow('Team', 'Naveed • Nimrah • Mehak'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _profileOption(
      IconData icon, String title, String subtitle, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 13)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  // ── DIALOGS ───────────────────────────────────────────────────────────────
  void _showRevenueDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHeader("Today's Revenue", Icons.monetization_on_outlined,
                const Color(0xFF0F766E)),
            const SizedBox(height: 16),
            _detailRow(
                'Total Revenue Today',
                'Rs ${(_stats['today_revenue'] ?? 0).toStringAsFixed(0)}',
                const Color(0xFF0F766E)),
            _detailRow('Total Transactions',
                '${_stats['today_transactions'] ?? 0}', AppColors.accent),
            _detailRow(
                'Average per Sale',
                (_stats['today_transactions'] != null &&
                        (_stats['today_transactions'] as num) > 0)
                    ? 'Rs ${((_stats['today_revenue'] ?? 0) / (_stats['today_transactions'] as num)).toStringAsFixed(0)}'
                    : 'Rs 0',
                AppColors.gold),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showSalesDetails() {
    final allTx = _getAllTransactions().take(5).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHeader("Today's Sales", Icons.receipt_outlined,
                const Color(0xFFF97316)),
            const SizedBox(height: 12),
            _detailRow(
                'Total Sales Today',
                '${_stats['today_transactions'] ?? 0} txn',
                const Color(0xFFF97316)),
            const SizedBox(height: 12),
            const Text('Recent Sales:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 13)),
            const SizedBox(height: 8),
            ...allTx.map((tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 6, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(tx['bill_id'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textPrimary))),
                      Text('Rs ${(tx['total'] ?? 0).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showMonthlyDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHeader('Monthly Revenue', Icons.calendar_month_outlined,
                const Color(0xFF0D9488)),
            const SizedBox(height: 16),
            _detailRow(
                'This Month Total',
                'Rs ${(_stats['monthly_revenue'] ?? 0).toStringAsFixed(0)}',
                const Color(0xFF0D9488)),
            _detailRow(
                "Today's Revenue",
                'Rs ${(_stats['today_revenue'] ?? 0).toStringAsFixed(0)}',
                AppColors.primary),
            _detailRow('Total Transactions This Month',
                '${_getAllTransactions().length}', AppColors.accent),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showLowStockDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHeader('Low Stock Alert', Icons.warning_amber_outlined,
                const Color(0xFFEA580C)),
            const SizedBox(height: 12),
            if (_lowStock.isEmpty)
              const Center(
                  child: Text('All products well stocked! ✅',
                      style: TextStyle(color: AppColors.success, fontSize: 14)))
            else ...[
              Text('${_lowStock.length} products need attention:',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ..._lowStock.map((p) {
                final isMap = p is Map;
                final name = isMap ? p['name'] : p[1];
                final qty = isMap ? p['quantity'] : p[9];
                final remark = isMap ? (p['stock_remark'] ?? '') : '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontSize: 13)),
                            Text(remark.isNotEmpty ? remark : 'Stock: $qty',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.error)),
                          ],
                        ),
                      ),
                      Text('Qty: $qty',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                              fontSize: 12)),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sheetHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _detailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    bool isWeight = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Add Product',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Product Name', Icons.label_outline),
                const SizedBox(height: 12),
                _dialogField(brandCtrl, 'Brand', Icons.business_outlined),
                const SizedBox(height: 12),
                _dialogField(
                    priceCtrl,
                    isWeight ? 'Price per kg' : 'Price per piece',
                    Icons.attach_money),
                const SizedBox(height: 12),
                if (!isWeight)
                  _dialogField(qtyCtrl, 'Quantity', Icons.inventory_2_outlined,
                      isNumber: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(
                        value: isWeight,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setS(() => isWeight = v)),
                    Text(isWeight ? 'Weight Based' : 'Fixed Price',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addProduct({
                  'name': nameCtrl.text,
                  'brand': brandCtrl.text,
                  'category': isWeight ? 'Vegetables' : 'Snacks',
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'weight_based': isWeight,
                  'quantity': int.tryParse(qtyCtrl.text) ?? 100,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(dynamic id, dynamic name, dynamic qty) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Add Stock',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: $name',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Current stock: $qty units',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            _dialogField(ctrl, 'Quantity to Add', Icons.add_box_outlined,
                isNumber: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final add = int.tryParse(ctrl.text) ?? 0;
              if (add <= 0) return;
              Navigator.pop(context);
              _updateStock(id, add);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(dynamic id, dynamic name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog() {
    _showLowStockDetails();
  }

  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _miniCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          Text(title,
              style:
                  const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _emptyWidget(String msg, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(msg,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
