import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:camera/camera.dart' as camera;
import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

enum CameraError {
  permissionDenied,
  noCamerasAvailable,
  initializationFailed,
  captureFailed,
  unknown,
}

class CameraResult<T> {
  final T? data;
  final CameraError? error;
  final String? message;

  const CameraResult._({this.data, this.error, this.message});

  factory CameraResult.success(T data) => CameraResult._(data: data);
  factory CameraResult.failure(CameraError error, [String? message]) => 
      CameraResult._(error: error, message: message);

  bool get isSuccess => data != null && error == null;
  bool get isFailure => error != null;
}

class CameraService {
  static CameraService? _instance;
  factory CameraService() => _instance ??= CameraService._();
  CameraService._();

  camera.CameraController? _controller;
  List<camera.CameraDescription> _availableCameras = [];
  bool _isInitialized = false;
  final StreamController<camera.CameraImage> _imageStreamController = StreamController<camera.CameraImage>.broadcast();

  camera.CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;
  List<camera.CameraDescription> get availableCameras => _availableCameras;
  Stream<camera.CameraImage> get imageStream => _imageStreamController.stream;

  /// Check camera permission status
  Future<CameraPermissionStatus> checkPermission() async {
    final status = await Permission.camera.status;
    
    switch (status) {
      case PermissionStatus.granted:
        return CameraPermissionStatus.granted;
      case PermissionStatus.denied:
        return CameraPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return CameraPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return CameraPermissionStatus.restricted;
      default:
        return CameraPermissionStatus.unknown;
    }
  }

  /// Request camera permission
  Future<CameraPermissionStatus> requestPermission() async {
    final status = await Permission.camera.request();
    
    switch (status) {
      case PermissionStatus.granted:
        return CameraPermissionStatus.granted;
      case PermissionStatus.denied:
        return CameraPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return CameraPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return CameraPermissionStatus.restricted;
      default:
        return CameraPermissionStatus.unknown;
    }
  }

  /// Initialize camera with permission check
  Future<CameraResult<camera.CameraController>> initializeCamera({
    camera.ResolutionPreset resolution = camera.ResolutionPreset.high,
    int? preferredCameraIndex,
  }) async {
    try {
      debugPrint('CameraService: Initializing camera...');
      // Check and request permission
      final permissionStatus = await checkPermission();
      if (permissionStatus != CameraPermissionStatus.granted) {
        debugPrint('CameraService: Camera permission not granted. Requesting...');
        final requestResult = await requestPermission();
        if (requestResult != CameraPermissionStatus.granted) {
          debugPrint('CameraService: Camera permission denied after request.');
          return CameraResult.failure(
            CameraError.permissionDenied,
            'Camera permission is required to scan items',
          );
        }
        debugPrint('CameraService: Camera permission granted after request.');
      }

      // Get available cameras  
      try {
        final cameras = await camera.availableCameras();
        _availableCameras = cameras;
        debugPrint('CameraService: Found ${_availableCameras.length} cameras.');
      } catch (e) {
        debugPrint('CameraService: Error getting available cameras: $e');
        return CameraResult.failure(
          CameraError.noCamerasAvailable,
          'No cameras found on this device',
        );
      }

      if (_availableCameras.isEmpty) {
        debugPrint('CameraService: No cameras available.');
        return CameraResult.failure(
          CameraError.noCamerasAvailable,
          'No cameras available on this device',
        );
      }

      // Select camera (prefer back camera for scanning)
      camera.CameraDescription selectedCamera;
      if (preferredCameraIndex != null && 
          preferredCameraIndex < _availableCameras.length) {
        selectedCamera = _availableCameras[preferredCameraIndex];
        debugPrint('CameraService: Selected camera by index: ${selectedCamera.name}');
      } else {
        // Try to find back camera first
        selectedCamera = _availableCameras.firstWhere(
          (cam) => cam.lensDirection == camera.CameraLensDirection.back,
          orElse: () => _availableCameras.first,
        );
        debugPrint('CameraService: Selected camera: ${selectedCamera.name} (back camera preferred)');
      }

      // Dispose existing controller
      await dispose();
      debugPrint('CameraService: Disposed previous controller (if any).');

      // Initialize new controller
      _controller = camera.CameraController(
        selectedCamera,
        resolution,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      debugPrint('CameraService: Controller initialized.');

      // Start image stream for continuous processing
      _controller!.startImageStream((camera.CameraImage image) {
        if (!_imageStreamController.isClosed) {
          _imageStreamController.add(image);
        }
      });
      debugPrint('CameraService: Image stream started.');

      return CameraResult.success(_controller!);
    } catch (e) {
      debugPrint('CameraService: Failed to initialize camera: $e');
      await dispose();
      return CameraResult.failure(
        CameraError.initializationFailed,
        'Failed to initialize camera: ${e.toString()}',
      );
    }
  }

  /// Capture image with error handling
  Future<CameraResult<camera.XFile>> captureImage() async {
    if (!isInitialized) {
      debugPrint('CameraService: Capture failed - camera not initialized.');
      return CameraResult.failure(
        CameraError.initializationFailed,
        'Camera not initialized',
      );
    }

    try {
      debugPrint('CameraService: Attempting to capture image...');
      // Add haptic feedback
      HapticFeedback.mediumImpact();
      
      final camera.XFile image = await _controller!.takePicture();
      debugPrint('CameraService: Image captured to ${image.path}');
      
      // Verify file exists and has content
      final file = File(image.path);
      if (!await file.exists() || await file.length() == 0) {
        debugPrint('CameraService: Captured image file is invalid or empty.');
        return CameraResult.failure(
          CameraError.captureFailed,
          'Captured image file is invalid',
        );
      }
      debugPrint('CameraService: Image capture successful.');
      return CameraResult.success(image);
    } catch (e) {
      debugPrint('CameraService: Failed to capture image: $e');
      return CameraResult.failure(
        CameraError.captureFailed,
        'Failed to capture image: ${e.toString()}',
      );
    }
  }

  /// Switch between available cameras
  Future<CameraResult<camera.CameraController>> switchCamera() async {
    if (_availableCameras.length <= 1) {
      return CameraResult.failure(
        CameraError.unknown,
        'No other cameras available',
      );
    }

    try {
      final currentCamera = _controller?.description;
      if (currentCamera == null) {
        return CameraResult.failure(
          CameraError.initializationFailed,
          'Current camera not available',
        );
      }

      // Find next camera
      final currentIndex = _availableCameras.indexOf(currentCamera);
      final nextIndex = (currentIndex + 1) % _availableCameras.length;
      
      return await initializeCamera(preferredCameraIndex: nextIndex);
    } catch (e) {
      return CameraResult.failure(
        CameraError.unknown,
        'Failed to switch camera: ${e.toString()}',
      );
    }
  }

  /// Toggle flash
  Future<CameraResult<camera.FlashMode>> toggleFlash() async {
    if (!isInitialized) {
      return CameraResult.failure(
        CameraError.initializationFailed,
        'Camera not initialized',
      );
    }

    try {
      final currentFlashMode = _controller!.value.flashMode;
      final newFlashMode = currentFlashMode == camera.FlashMode.off 
          ? camera.FlashMode.torch 
          : camera.FlashMode.off;
      
      await _controller!.setFlashMode(newFlashMode);
      return CameraResult.success(newFlashMode);
    } catch (e) {
      return CameraResult.failure(
        CameraError.unknown,
        'Failed to toggle flash: ${e.toString()}',
      );
    }
  }

  /// Dispose camera controller
  Future<void> dispose() async {
    _isInitialized = false;
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  /// Stop the image stream
  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }
}
