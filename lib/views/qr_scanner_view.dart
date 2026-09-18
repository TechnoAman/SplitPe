import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/upi_validator.dart';
import '../theme/app_theme.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  late AnimationController _laserController;
  bool _isTorchOn = false;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _handleQrResult(rawValue);
        break;
      }
    }
  }

  void _handleQrResult(String rawData) {
    final validation = UpiValidator.validate(rawData);
    if (!validation.isValid) {
      _showInvalidQrDialog(validation.errorMessage ?? 'Invalid UPI QR format.');
      return;
    }

    _hasScanned = true;
    Navigator.pop(context, validation.toLegacyMap());
  }

  void _showInvalidQrDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.alertRed, width: 1.5),
        ),
        icon: const Icon(Icons.gpp_bad_rounded, color: AppColors.alertRed, size: 36),
        title: const Text(
          'INVALID OR UNSAFE QR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 12,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _hasScanned = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Scan Again', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'PASTE UPI LINK / VPA',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. upi://pay?pa=store@okhdfcbank&pn=Store',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleQrResult(textController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.black,
            ),
            child: const Text('Use QR Data', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'SCAN MERCHANT QR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isTorchOn ? AppColors.goldenYellow : AppColors.textSecondary,
            ),
            onPressed: () async {
              await _scannerController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: AppColors.textSecondary),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Fullscreen Camera View (Anchored Full Viewport)
            Positioned.fill(
              child: MobileScanner(
                controller: _scannerController,
                fit: BoxFit.cover,
                onDetect: _onDetect,
                errorBuilder: (context, error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Camera unavailable on this device/platform.',
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showManualEntryDialog,
                            icon: const Icon(Icons.paste_rounded, color: Colors.black, size: 16),
                            label: const Text('Paste UPI Link / Demo Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Translucent Mask with Centered Cutout
            Positioned.fill(
              child: CustomPaint(
                painter: _ScannerOverlayPainter(
                  cutoutSize: const Size(260, 260),
                  borderColor: AppColors.primaryGreen,
                ),
              ),
            ),

            // 3. Mathematical Center Viewfinder & Laser (Frame 0 Anchored)
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  children: [
                    // Corner Brackets
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryGreen.withAlpha(120), width: 1.0),
                        ),
                      ),
                    ),

                    // Animated Smooth Laser Line
                    AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Positioned(
                          top: _laserController.value * 250,
                          left: 8,
                          right: 8,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.primaryGreen,
                                  blurRadius: 8,
                                  spreadRadius: 1.5,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 4. Bottom Hint & Demo Shortcuts
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0D10).withAlpha(220),
                      border: Border.all(color: const Color(0xFF27272A)),
                    ),
                    child: const Text(
                      'ALIGN MERCHANT QR WITHIN THE FRAME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Demo QR Presets
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _demoQrChip(
                          'Gupta Kirana ₹3,850',
                          'upi://pay?pa=guptakirana@okhdfcbank&pn=Gupta%20Kirana%20Store&am=3850',
                        ),
                        const SizedBox(width: 8),
                        _demoQrChip(
                          'Sharma Sweets ₹7,500',
                          'upi://pay?pa=sharmasweets@okaxis&pn=Sharma%20Sweets&am=7500',
                        ),
                        const SizedBox(width: 8),
                        _demoQrChip(
                          'Social Bistro ₹6,800',
                          'upi://pay?pa=socialbistro@paytm&pn=Social%20Bistro&am=6800',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoQrChip(String label, String upiUri) {
    return InkWell(
      onTap: () => _handleQrResult(upiUri),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF16171C),
          border: Border.all(color: const Color(0xFF2C2D36)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 14, color: AppColors.primaryGreen),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Mask Painter that punches a sharp center cutout
class _ScannerOverlayPainter extends CustomPainter {
  final Size cutoutSize;
  final Color borderColor;

  _ScannerOverlayPainter({
    required this.cutoutSize,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withAlpha(140)
      ..style = PaintingStyle.fill;

    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize.width,
      height: cutoutSize.height,
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRect(cutoutRect);

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
