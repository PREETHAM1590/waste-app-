import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart' as camera;
import 'package:google_fonts/google_fonts.dart';
import '../services/classification_service.dart';
import '../models/waste_item.dart';
import '../services/camera_service.dart';
import '../wallet/services/waste_coin_service.dart';
import '../core/theme/app_theme.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  final CameraService _cameraService = CameraService();
  final WasteCoinService _wasteCoinService = WasteCoinService.instance; // Initialize WasteCoinService
  final ClassificationService _classificationService = ClassificationService(); // Initialize ClassificationService
  String? _error;
  bool _isFlashOn = false;
  WasteItem? _classifiedWasteItem; // To store the classification result

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final result = await _cameraService.initializeCamera(
      resolution: camera.ResolutionPreset.medium, // Changed to medium
    );

    if (result.isFailure) {
      if (mounted) {
        setState(() {
          _error = result.message;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _error = null;
        });
        debugPrint('Camera initialized successfully!');
        _startContinuousClassification(); // Re-enable continuous classification
      }
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  // Continuous classification disabled to avoid isolate errors
  // Users can classify by capturing images manually
  void _startContinuousClassification() {
    // Continuous classification has been disabled to prevent BackgroundIsolateBinaryMessenger errors
    // The manual capture functionality works perfectly for image classification
    debugPrint('Continuous classification is disabled. Use manual capture instead.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Scan Waste',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final result = await _cameraService.toggleFlash();
              if (result.isSuccess && mounted) {
                setState(() {
                  _isFlashOn = result.data == camera.FlashMode.torch;
                });
              } else if (result.isFailure) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.message ?? 'Failed to toggle flash')),
                  );
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isFlashOn 
                          ? AppTheme.warningYellow.withOpacity(0.4)
                          : Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildCameraBody(),
      floatingActionButton: _buildGlassScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGlassScanButton() {
    return GestureDetector(
      onTap: (_cameraService.isInitialized) ? () async {
          if (_classifiedWasteItem != null) {
            // If a result is already displayed, pressing the button resets the scan
            setState(() {
              _classifiedWasteItem = null;
            });
          } else {
            // Otherwise, capture and classify a single image
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            
            try {
              final imageResult = await _cameraService.captureImage();
              if (imageResult.isFailure) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(imageResult.message ?? 'Failed to capture image')),
                );
                return;
              }

              final image = imageResult.data!;
              if (!mounted) return;

              final wasteItem = await _classificationService.classifyImage(File(image.path));

              if (!mounted) return;
              setState(() {
                _classifiedWasteItem = wasteItem;
              });
            } catch (e) {
              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Failed to classify image: $e')),
              );
            }
          }
        } : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _classifiedWasteItem == null
                  ? AppTheme.primaryBlue.withOpacity(0.4)
                  : AppTheme.warningOrange.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: _classifiedWasteItem == null
                    ? LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                      )
                    : LinearGradient(
                        colors: [AppTheme.warningOrange, AppTheme.warningYellow],
                      ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 3,
                ),
              ),
              child: Icon(
                _classifiedWasteItem == null 
                    ? Icons.camera_alt_rounded 
                    : Icons.refresh_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
                _initializeCamera();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_cameraService.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ensure the controller is not null before creating CameraPreview
    if (_cameraService.controller == null || !_cameraService.controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        camera.CameraPreview(_cameraService.controller!),
        if (_classifiedWasteItem != null) _buildOverlay(context, _classifiedWasteItem!),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context, WasteItem wasteItem) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Top Result Card
        Padding(
          padding: const EdgeInsets.all(20),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: AppTheme.cornerRadiusLarge,
            blur: 30,
            opacity: 0.3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: wasteItem.recyclable
                          ? [AppTheme.successGreen, const Color(0xFF10B981)]
                          : [AppTheme.errorRed, AppTheme.errorPink],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (wasteItem.recyclable 
                            ? AppTheme.successGreen 
                            : AppTheme.errorRed).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    wasteItem.recyclable ? Icons.recycling_rounded : Icons.delete_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wasteItem.name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${wasteItem.points} Eco-Points',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (wasteItem.recyclable 
                        ? AppTheme.successGreen 
                        : AppTheme.errorRed).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: wasteItem.recyclable 
                          ? AppTheme.successGreen 
                          : AppTheme.errorRed,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${(wasteItem.confidence * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Details Sheet
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Disposal Instructions',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      wasteItem.disposalInstructions,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.warningOrange, AppTheme.warningYellow],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pro Tips',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...wasteItem.tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.warningYellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            text: 'Confirm',
                            icon: Icons.check_circle_rounded,
                            colors: [AppTheme.successGreen, const Color(0xFF10B981)],
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              if (_classifiedWasteItem != null) {
                                final success = await _wasteCoinService.rewardForCorrectClassification(
                                  wasteType: _classifiedWasteItem!.name,
                                  isCorrect: true,
                                );

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      content: GlassCard(
                                        padding: const EdgeInsets.all(16),
                                        borderRadius: 12,
                                        blur: 20,
                                        opacity: 0.3,
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [AppTheme.warningYellow, AppTheme.warningOrange],
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.monetization_on_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Earned ${WasteCoinService.correctClassificationReward} SOL!',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                              setState(() {
                                _classifiedWasteItem = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            text: 'Retry',
                            icon: Icons.refresh_rounded,
                            colors: [AppTheme.errorRed, AppTheme.errorPink],
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _classifiedWasteItem = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
