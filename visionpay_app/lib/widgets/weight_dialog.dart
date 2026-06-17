import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';

/// Call this to show the weight dialog for a weight-based product.
/// Returns weight in kg, or null if cancelled.
Future<double?> showWeightDialog(
    BuildContext context, String productName, String weightServiceUrl) {
  return showDialog<double>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WeightDialog(
      productName: productName,
      weightServiceUrl: weightServiceUrl,
    ),
  );
}

class _WeightDialog extends StatefulWidget {
  final String productName;
  final String weightServiceUrl;
  const _WeightDialog(
      {required this.productName, required this.weightServiceUrl});

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  double _weightKg = 0.0;
  bool _connected = false;
  bool _liveMode = false;
  bool _loading = false;
  Timer? _liveTimer;

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  Future<void> _readOnce() async {
    setState(() => _loading = true);
    try {
      final res = await http
          .get(Uri.parse('${widget.weightServiceUrl}/weight'))
          .timeout(const Duration(seconds: 5));
      final data = json.decode(res.body);
      setState(() {
        _weightKg = (data['weight_kg'] as num).toDouble();
        _connected = data['connected'] ?? false;
      });
    } catch (_) {
      setState(() => _connected = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleLive() {
    if (_liveMode) {
      _liveTimer?.cancel();
      setState(() => _liveMode = false);
    } else {
      setState(() => _liveMode = true);
      _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) => _readOnce());
      _readOnce();
    }
  }

  Future<void> _tare() async {
    try {
      await http
          .post(Uri.parse('${widget.weightServiceUrl}/tare'))
          .timeout(const Duration(seconds: 3));
      setState(() => _weightKg = 0.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.scale, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weigh Product',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(widget.productName,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, null),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Weight Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF0D5C56)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '${(_weightKg * 1000).toStringAsFixed(0)} g',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_weightKg.toStringAsFixed(3)} kg',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _connected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: _connected ? Colors.greenAccent : Colors.red[200],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _connected ? 'Scale connected' : 'Scale not connected',
                        style: TextStyle(
                            color: _connected
                                ? Colors.greenAccent
                                : Colors.red[200],
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons row
            Row(
              children: [
                // Read Scale
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _readOnce,
                    icon: _loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh, size: 16),
                    label: const Text('Read'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                // Live toggle
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleLive,
                    icon: Icon(
                        _liveMode ? Icons.stop_circle : Icons.play_circle,
                        size: 16),
                    label: Text(_liveMode ? 'Stop' : 'Live'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor:
                            _liveMode ? Colors.red : AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                // Tare
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _tare,
                    icon: const Icon(Icons.exposure_zero, size: 16),
                    label: const Text('Tare'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _weightKg > 0
                    ? () => Navigator.pop(context, _weightKg)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _weightKg > 0
                      ? 'Confirm  ${(_weightKg * 1000).toStringAsFixed(0)}g'
                      : 'Read weight first',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
