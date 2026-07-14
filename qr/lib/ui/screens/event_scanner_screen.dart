import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/event.dart';
import '../../models/scanned_booking.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class EventScannerScreen extends StatefulWidget {
  final Event event;

  const EventScannerScreen({super.key, required this.event});

  @override
  State<EventScannerScreen> createState() => _EventScannerScreenState();
}

class _EventScannerScreenState extends State<EventScannerScreen> {
  final _api = Get.find<ApiService>();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  
  bool _isProcessing = false;
  bool _isFlashOn = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final scannedValue = barcode.rawValue!.trim();
    if (scannedValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Provide immediate haptic feedback
    Feedback.forTap(context);

    // Call check-in API
    final result = await _api.checkInTicket(scannedValue, widget.event.id);
    
    if (mounted) {
      _showResultOverlay(result);
    }
  }

  void _showResultOverlay(Map<String, dynamic> result) {
    final bool success = result['success'] as bool? ?? false;
    final bool isConnectionError = result['connectionError'] as bool? ?? false;
    final String message = result['message'] as String? ?? '';
    final dynamic bookingData = result['booking'];
    
    ScannedBooking? booking;
    if (bookingData != null) {
      booking = ScannedBooking.fromJson(bookingData as Map<String, dynamic>);
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Icon & Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (success 
                        ? AppColors.successGreen 
                        : (isConnectionError ? Colors.amber.shade700 : AppColors.accentCoral)).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    success 
                        ? Icons.check_circle_rounded 
                        : (isConnectionError ? Icons.wifi_off_rounded : Icons.cancel_rounded),
                    color: success 
                        ? AppColors.successGreen 
                        : (isConnectionError ? Colors.amber.shade800 : AppColors.accentCoral),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        success 
                            ? 'Access Granted' 
                            : (isConnectionError ? 'System Offline' : 'Access Denied'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: success 
                              ? AppColors.successGreen 
                              : (isConnectionError ? Colors.amber.shade800 : AppColors.accentCoral),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28, thickness: 0.8),

            // Scanned Ticket Details (if parsed)
            if (booking != null) ...[
              _buildDetailRow('ATTENDEE', booking.username),
              _buildDetailRow('EMAIL', booking.email),
              _buildDetailRow('TICKET CODE', '#${booking.code}'),
              _buildDetailRow('TICKET TYPE', booking.status.toUpperCase()),
              if (booking.checkedInAt != null)
                _buildDetailRow(
                  'CHECKED IN AT',
                  DateFormat('hh:mm a').format(booking.checkedInAt!.toLocal()),
                ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    isConnectionError 
                        ? 'Verification could not be performed.' 
                        : 'Invalid or unverified database record.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            
            // Scan Next Button
            ElevatedButton(
              onPressed: () {
                Get.back();
                setState(() {
                  _isProcessing = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: success 
                    ? AppColors.successGreen 
                    : (isConnectionError ? Colors.amber.shade700 : AppColors.primaryDark),
              ),
              child: Text(isConnectionError ? 'Retry Scanning' : 'Scan Next Ticket'),
            ),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.event.title, style: const TextStyle(fontSize: 15)),
            Text('Event Code: #${widget.event.code}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner viewport
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Scan Box Overlay Mask
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing 
                      ? Colors.orange.shade500 
                      : AppColors.secondaryBlue, 
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 200,
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          // Instruction Text
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isProcessing ? 'Verifying ticket...' : 'Align ticket QR code inside the box to verify.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
