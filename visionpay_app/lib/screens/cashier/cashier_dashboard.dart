import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../theme/colors.dart';
import '../login_screen.dart';
import 'package:camera/camera.dart';

class CashierDashboard extends StatefulWidget {
  final String fullName;
  const CashierDashboard({super.key, required this.fullName});

  @override
  State<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  final List<Map<String, dynamic>> _cartItems = [];
  bool _isDetecting = false;
  String _statusMessage = 'Ready — Place products in front of camera';
  Color _statusColor = const Color(0xFF6B7280);
  final String _apiBase = 'https://mehakrazzaq2-visionpay-api.hf.space';
  final String _weightBase = 'http://localhost:8001';

  // Camera
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraInitialized = false;

  // WebSocket
  WebSocketChannel? _wsChannel;

  double get _cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + (item['total'] as double));

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _initCamera();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _wsChannel?.sink.close();
    super.dispose();
  }

  void _connectWebSocket() {
    try {
      final wsUrl = _apiBase.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
      _wsChannel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws'));
      _wsChannel!.stream.listen((msg) {
        final data = json.decode(msg as String);
        if (data['type'] == 'products_detected') {
          final products = List<Map<String, dynamic>>.from(data['products']);
          if (mounted) _handleDetectedProducts(products);
        }
      }, onDone: () {
        Future.delayed(const Duration(seconds: 3), _connectWebSocket);
      }, onError: (_) {
        Future.delayed(const Duration(seconds: 3), _connectWebSocket);
      });
    } catch (_) {}
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final backCamera = _cameras!.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras![0],
        );
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() => _cameraInitialized = true);
      }
    } catch (e) {
      print('Camera error: $e');
    }
  }

  // ── Capture & Detect ──────────────────────────────────────────────────────
  Future<void> _captureAndDetect() async {
    setState(() {
      _isDetecting = true;
      _statusMessage = '🔍 Detecting products...';
      _statusColor = const Color(0xFFF9A602);
    });

    try {
      if (_cameraInitialized && _cameraController != null) {
        // Real camera capture
        final image = await _cameraController!.takePicture();
        final imageBytes = await image.readAsBytes();

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_apiBase/detect'),
        );
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'capture.jpg',
        ));

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (data['products'] != null) {
          final products = List<Map<String, dynamic>>.from(data['products']);
          _handleDetectedProducts(products);
        } else {
          setState(() {
            _statusMessage = '⚠️ No products detected!';
            _statusColor = AppColors.gold;
          });
        }
      } else {
        // Mock detection — camera not available
        await Future.delayed(const Duration(seconds: 1));
        _showMockDetectionResult();
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Detection failed!';
        _statusColor = const Color(0xFFDC2626);
      });
      _showErrorSnack('Server unreachable — check your internet connection');
    } finally {
      setState(() => _isDetecting = false);
    }
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white70,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ));
  }

  void _showMockDetectionResult() {
    final mockProducts = [
      {
        'name': 'CocoMo',
        'brand': 'LU',
        'weight_based': false,
        'price_per_unit': 20.0,
        'price_per_kg': 0.0,
        'status': 'ready',
        'id': 3,
      },
      {
        'name': 'Tomato',
        'brand': 'Local',
        'weight_based': true,
        'price_per_unit': 0.0,
        'price_per_kg': 100.0,
        'status': 'weight_required',
        'id': 48,
      },
      {
        'name': 'Lays French Cheese',
        'brand': 'Lays',
        'weight_based': false,
        'price_per_unit': 20.0,
        'price_per_kg': 0.0,
        'status': 'ready',
        'id': 4,
      },
    ];
    _handleDetectedProducts(mockProducts);
  }

  void _handleDetectedProducts(List<Map<String, dynamic>> products) {
    int weightCount = 0;
    for (final product in products) {
      if (product['weight_based'] == true ||
          product['status'] == 'weight_required') {
        weightCount++;
        Future.delayed(Duration(milliseconds: 300 * weightCount), () {
          if (mounted) _showWeightDialog(product);
        });
      } else {
        _addToCart(
          name: product['name'],
          brand: product['brand'] ?? '',
          price: (product['price_per_unit'] ?? 0).toDouble(),
          isWeight: false,
          productId: product['id'],
        );
      }
    }

    setState(() {
      _statusMessage = '✅ ${products.length} product(s) detected!';
      _statusColor = const Color(0xFF16A34A);
    });
  }

  void _addToCart({
    required String name,
    required String brand,
    required double price,
    required bool isWeight,
    double? weightKg,
    int? productId,
  }) {
    final total = isWeight ? price * (weightKg ?? 0) : price;
    setState(() {
      _cartItems.add({
        'name': name,
        'brand': brand,
        'price': price,
        'is_weight': isWeight,
        'weight_kg': weightKg,
        'total': total,
        'product_id': productId,
      });
    });
  }

  // ── Weight Dialog ─────────────────────────────────────────────────────────
  void _showWeightDialog(Map<String, dynamic> product,
      {bool isManual = false}) {
    final weightController = TextEditingController();
    final pricePerKg = (product['price_per_kg'] ?? 0).toDouble();
    String unit = 'kg';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) {
          double weightKg = 0;
          if (weightController.text.isNotEmpty) {
            final raw = double.tryParse(weightController.text) ?? 0;
            weightKg = unit == 'g' ? raw / 1000 : raw;
          }
          final previewTotal = pricePerKg * weightKg;

          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.scale,
                            color: AppColors.gold, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['name'],
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          Text('Rs $pricePerKg per kg',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Unit: ',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      _unitBtn(
                          'kg',
                          unit,
                          () => setS(() {
                                unit = 'kg';
                                weightController.clear();
                              })),
                      const SizedBox(width: 8),
                      _unitBtn(
                          'g',
                          unit,
                          () => setS(() {
                                unit = 'g';
                                weightController.clear();
                              })),
                      const Spacer(),
                      if (isManual)
                        const Text('Manual Entry',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.accent)),
                      if (!isManual)
                        const Text('Load Cell',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Enter Weight ($unit)',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    onChanged: (v) => setS(() {}),
                    decoration: InputDecoration(
                      hintText: unit == 'kg' ? 'e.g. 0.5' : 'e.g. 500',
                      suffixText: unit,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.border.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2)),
                    ),
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.scale, size: 16),
                        label: const Text('Read from Scale'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          try {
                            final res = await http
                                .get(Uri.parse('$_weightBase/weight'))
                                .timeout(const Duration(seconds: 4));
                            final d = json.decode(res.body);
                            final g = (d['weight_g'] as num).toDouble();
                            if (g > 0) {
                              setS(() {
                                unit = 'g';
                                weightController.text = g.toStringAsFixed(0);
                              });
                            }
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Scale not connected — run weight_service.py'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                  if (weightController.text.isNotEmpty && weightKg > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Weight',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              Text('${weightKg.toStringAsFixed(3)} kg',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Rate',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              Text('Rs $pricePerKg/kg',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12)),
                            ],
                          ),
                          const Divider(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Price',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                              Text('Rs ${previewTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (weightController.text.isEmpty) return;
                        final raw = double.tryParse(weightController.text);
                        if (raw == null || raw <= 0) return;
                        final weightKgFinal = unit == 'g' ? raw / 1000 : raw;
                        Navigator.pop(context);
                        _addToCart(
                          name: product['name'],
                          brand: product['brand'] ?? '',
                          price: pricePerKg,
                          isWeight: true,
                          weightKg: weightKgFinal,
                          productId: product['id'],
                        );
                        setState(() {
                          _statusMessage =
                              '✅ Added: ${product['name']} (${weightKgFinal.toStringAsFixed(3)}kg)';
                          _statusColor = const Color(0xFF16A34A);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('✅  Confirm Weight',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _unitBtn(String label, String selected, VoidCallback onTap) {
    final isSelected = label == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  // ── Manual Entry ──────────────────────────────────────────────────────────
  void _showManualEntry() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    Map<String, dynamic>? foundProduct;
    bool searching = false;
    String error = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text('Manual Entry',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Product Name',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Tomato, CocoMo, Lays...',
                    hintStyle: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.primary, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.border.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                  onChanged: (_) => setS(() {
                    foundProduct = null;
                    error = '';
                  }),
                ),
                const SizedBox(height: 12),
                const Text('Weight (kg/g) or Quantity',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'e.g. 0.5 or 500g or 1',
                    hintStyle: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    prefixIcon: const Icon(Icons.scale_outlined,
                        color: AppColors.gold, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.border.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                  onChanged: (_) => setS(() {}),
                ),
                if (foundProduct != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.success, size: 16),
                            SizedBox(width: 6),
                            Text('Product Found!',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(foundProduct!['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          foundProduct!['weight_based'] == true
                              ? 'Rs ${foundProduct!['price_per_kg']}/kg'
                              : 'Rs ${foundProduct!['price_per_unit']}/piece',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (qtyCtrl.text.isNotEmpty) ...[
                          const Divider(height: 12),
                          Builder(builder: (context) {
                            final raw = double.tryParse(qtyCtrl.text
                                    .replaceAll(RegExp(r'[^0-9.]'), '')) ??
                                0;
                            final isGrams =
                                qtyCtrl.text.toLowerCase().contains('g');
                            final isWeight =
                                foundProduct!['weight_based'] == true;
                            double total = 0;
                            String detail = '';
                            if (isWeight) {
                              final kg = isGrams ? raw / 1000 : raw;
                              final pricePerKg =
                                  (foundProduct!['price_per_kg'] ?? 0)
                                      .toDouble();
                              total = pricePerKg * kg;
                              detail =
                                  '${kg.toStringAsFixed(3)}kg × Rs $pricePerKg';
                            } else {
                              final qty = raw.toInt();
                              final pricePerUnit =
                                  (foundProduct!['price_per_unit'] ?? 0)
                                      .toDouble();
                              total = pricePerUnit * qty;
                              detail = '$qty × Rs $pricePerUnit';
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(detail,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                Text('Rs ${total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                              ],
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ],
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.error.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Text(error,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: searching
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            final qtyText = qtyCtrl.text.trim();
                            if (name.isEmpty) {
                              setS(() => error = 'Please enter product name');
                              return;
                            }
                            if (qtyText.isEmpty) {
                              setS(() =>
                                  error = 'Please enter weight or quantity');
                              return;
                            }
                            setS(() {
                              searching = true;
                              error = '';
                            });
                            try {
                              final res = await http.get(Uri.parse(
                                  '$_apiBase/product/search?name=$name'));
                              if (res.statusCode == 200) {
                                final data = json.decode(res.body);
                                if (data['product'] != null) {
                                  setS(() {
                                    foundProduct = Map<String, dynamic>.from(
                                        data['product']);
                                    searching = false;
                                  });
                                  if (qtyText.isNotEmpty) {
                                    final raw = double.tryParse(
                                            qtyText.replaceAll(
                                                RegExp(r'[^0-9.]'), '')) ??
                                        0;
                                    final isGrams =
                                        qtyText.toLowerCase().contains('g');
                                    final isWeight =
                                        foundProduct!['weight_based'] == true;
                                    if (isWeight) {
                                      final kg = isGrams ? raw / 1000 : raw;
                                      final pricePerKg =
                                          (foundProduct!['price_per_kg'] ?? 0)
                                              .toDouble();
                                      Navigator.pop(context);
                                      _addToCart(
                                        name: foundProduct!['name'],
                                        brand: foundProduct!['brand'] ?? '',
                                        price: pricePerKg,
                                        isWeight: true,
                                        weightKg: kg,
                                        productId: foundProduct!['id'],
                                      );
                                    } else {
                                      final qty = raw.toInt();
                                      final pricePerUnit =
                                          (foundProduct!['price_per_unit'] ?? 0)
                                              .toDouble();
                                      Navigator.pop(context);
                                      for (int i = 0; i < qty; i++) {
                                        _addToCart(
                                          name: foundProduct!['name'],
                                          brand: foundProduct!['brand'] ?? '',
                                          price: pricePerUnit,
                                          isWeight: false,
                                          productId: foundProduct!['id'],
                                        );
                                      }
                                    }
                                    setState(() {
                                      _statusMessage =
                                          '✅ Added: ${foundProduct!['name']}';
                                      _statusColor = AppColors.success;
                                    });
                                  }
                                } else {
                                  setS(() {
                                    error =
                                        'Product "$name" not found in database';
                                    searching = false;
                                  });
                                }
                              }
                            } catch (e) {
                              setS(() {
                                error = 'Connection error — check server';
                                searching = false;
                              });
                            }
                          },
                    icon: searching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(searching ? 'Searching...' : 'Process',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Barcode ───────────────────────────────────────────────────────────────
  void _showBarcodeEntry() {
    final barcodeCtrl = TextEditingController();
    bool searching = false;
    String error = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.qr_code_scanner,
                        color: AppColors.primary, size: 24),
                    SizedBox(width: 10),
                    Text('Barcode Lookup',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: barcodeCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Enter or Scan Barcode',
                    prefixIcon:
                        const Icon(Icons.qr_code, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                  onSubmitted: (v) async {
                    setS(() {
                      searching = true;
                      error = '';
                    });
                    await _lookupBarcode(
                        v,
                        context,
                        setS,
                        (err) => setS(() {
                              error = err;
                              searching = false;
                            }));
                  },
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(error,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: searching
                        ? null
                        : () async {
                            setS(() {
                              searching = true;
                              error = '';
                            });
                            await _lookupBarcode(
                                barcodeCtrl.text,
                                context,
                                setS,
                                (err) => setS(() {
                                      error = err;
                                      searching = false;
                                    }));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: searching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Lookup',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _lookupBarcode(String barcode, BuildContext ctx, Function setS,
      Function(String) onError) async {
    if (barcode.trim().isEmpty) {
      onError('Please enter a barcode');
      return;
    }
    try {
      final response =
          await http.get(Uri.parse('$_apiBase/product/barcode/$barcode'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['product'] != null) {
          Navigator.pop(ctx);
          final p = data['product'];
          final isWeight = p['weight_based'] == true;
          if (isWeight) {
            _showWeightDialog({
              'name': p['name'],
              'brand': p['brand'] ?? '',
              'weight_based': true,
              'price_per_kg': p['price_per_kg'] ?? 0,
              'id': p['id'],
            });
          } else {
            _addToCart(
              name: p['name'],
              brand: p['brand'] ?? '',
              price: (p['price_per_unit'] ?? 0).toDouble(),
              isWeight: false,
              productId: p['id'],
            );
            setState(() {
              _statusMessage = '✅ Added via barcode: ${p['name']}';
              _statusColor = AppColors.success;
            });
          }
        } else {
          onError('Product not found for this barcode');
        }
      } else {
        onError('Barcode lookup failed');
      }
    } catch (e) {
      onError('Connection error — check server');
    }
  }

  // ── Generate Bill ─────────────────────────────────────────────────────────
  Future<void> _generateBill() async {
    if (_cartItems.isEmpty) return;

    try {
      final billId = 'VP-${DateTime.now().millisecondsSinceEpoch}';

      await http.post(
        Uri.parse('$_apiBase/generate-bill'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'products': _cartItems
              .map((item) => {
                    'name': item['name'],
                    'brand': item['brand'],
                    'weight_based': item['is_weight'],
                    'price_per_unit': item['is_weight'] ? 0 : item['price'],
                    'price_per_kg': item['is_weight'] ? item['price'] : 0,
                    'weight_kg': item['weight_kg'],
                    'quantity': 1,
                  })
              .toList(),
        }),
      );

      await http.post(
        Uri.parse('$_apiBase/save-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'bill_id': billId,
          'cashier': widget.fullName,
          'total': _cartTotal,
          'items_count': _cartItems.length,
          'items_json': json.encode(_cartItems),
        }),
      );

      for (final item in _cartItems) {
        if (item['product_id'] != null && item['is_weight'] == false) {
          await http.put(
            Uri.parse('$_apiBase/product/stock/${item['product_id']}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'quantity': -1}),
          );
        }
      }

      _showReceiptDialog(billId);
    } catch (e) {
      _showReceiptDialog('VP-${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  void _showReceiptDialog(String billId) {
    final now = DateTime.now();
    final timeStr =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF0D5C56)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 36),
                      const SizedBox(height: 8),
                      const Text('Transaction Complete!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('VisionPay — AI Grocery Billing',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _receiptRow('Bill ID', billId),
                _receiptRow('Cashier', widget.fullName),
                _receiptRow('Date & Time', timeStr),
                _receiptRow('Payment', 'Cash'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(
                              child: Text('Item',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.textSecondary))),
                          Text('Price',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const Divider(height: 10),
                      ..._cartItems.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w500)),
                                      if (item['is_weight'] == true)
                                        Text(
                                            '${item['weight_kg']?.toStringAsFixed(3)}kg × Rs ${item['price']}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color:
                                                    AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Text(
                                    'Rs ${(item['total'] as double).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                        fontSize: 12)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary)),
                      Text('Rs ${_cartTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Thank you for shopping!',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.print_outlined,
                            size: 16, color: AppColors.primary),
                        label: const Text('Print',
                            style: TextStyle(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _cartItems.clear();
                            _statusMessage = '🔄 Ready — New sale';
                            _statusColor = AppColors.textSecondary;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('New Sale'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
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

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      Expanded(flex: 3, child: _buildCameraPanel()),
                      Expanded(flex: 2, child: _buildCartPanel()),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(flex: 5, child: _buildCameraPanel()),
                      Expanded(flex: 2, child: _buildCartPanel()),
                    ],
                  ),
          ),
        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('VisionPay',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text('Cashier: ${widget.fullName}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Online',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.error),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.08),
        border:
            Border(bottom: BorderSide(color: _statusColor.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(_statusMessage,
              style: TextStyle(
                  fontSize: 12,
                  color: _statusColor,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCameraPanel() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0D5C56)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Camera Feed',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: _cameraInitialized
                                  ? const Color(0xFF4ADE80)
                                  : Colors.orange,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(_cameraInitialized ? 'LIVE' : 'NO CAM',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Camera preview or placeholder
          Expanded(
            child: _cameraInitialized && _cameraController != null
                ? ClipRect(
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize?.height ??
                              1920,
                          height: _cameraController!.value.previewSize?.width ??
                              1080,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF042F2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 56, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 10),
                        Text('Camera Initializing...',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.5))),
                        const SizedBox(height: 4),
                        Text('Allow camera permission\nif prompted',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.3))),
                      ],
                    ),
                  ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isDetecting ? null : _captureAndDetect,
                    icon: _isDetecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.camera_alt, size: 18),
                    label: Text(
                        _isDetecting ? 'Detecting...' : 'Capture & Detect',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showManualEntry,
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Manual',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                              color: AppColors.primary.withOpacity(0.6)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showBarcodeEntry,
                        icon: const Icon(Icons.qr_code, size: 14),
                        label: const Text('Barcode',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: BorderSide(
                              color: AppColors.gold.withOpacity(0.6)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: AppColors.gold.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              gradient:
                  LinearGradient(colors: [AppColors.gold, Color(0xFFE08B00)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Cart',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${_cartItems.length} items',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 40, color: AppColors.gold.withOpacity(0.3)),
                        const SizedBox(height: 8),
                        const Text('Cart is empty',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.border.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: item['is_weight']
                                    ? AppColors.gold.withOpacity(0.15)
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item['is_weight']
                                    ? Icons.scale
                                    : Icons.label_outline,
                                color: item['is_weight']
                                    ? AppColors.gold
                                    : AppColors.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppColors.textPrimary)),
                                  Text(
                                    item['is_weight']
                                        ? '${item['weight_kg']?.toStringAsFixed(3)}kg'
                                        : item['brand'],
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    'Rs ${(item['total'] as double).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 12)),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _cartItems.removeAt(index)),
                                  child: const Icon(Icons.close,
                                      size: 14, color: AppColors.error),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.3))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Items',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    Text('${_cartItems.length}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 3),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tax (0%)',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    Text('Rs 0',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                Divider(color: AppColors.border.withOpacity(0.3), height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text('Rs ${_cartTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _cartItems.isEmpty
                          ? null
                          : () => setState(() => _cartItems.clear()),
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: AppColors.error.withOpacity(0.4)),
                        foregroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child:
                          const Text('Clear', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cartItems.isEmpty ? null : _generateBill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        child: const Text('Generate Bill',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
