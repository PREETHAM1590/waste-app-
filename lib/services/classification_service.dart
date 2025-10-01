import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/waste_item.dart';
import 'user_stats_service.dart';

/// Service for classifying waste items from images
class ClassificationService {
  static final ClassificationService _instance = ClassificationService._internal();
  factory ClassificationService() => _instance;
  ClassificationService._internal();

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  /// Load the TFLite model and labels
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final labelsString = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsString
          .split('\n')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .map((line) {
            // Parse format "0|BATTERY" or "1|BIODEGRADABLE"
            final parts = line.split('|');
            return parts.length > 1 ? parts[1] : parts[0];
          })
          .toList();
      _isModelLoaded = true;
      print('Model and labels loaded successfully!');
      print('Loaded ${_labels!.length} classes: $_labels');
    } catch (e) {
      print('Failed to load model or labels: $e');
      _isModelLoaded = false;
    }
  }

  /// Preprocess the image for model input
  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) {
      throw Exception('Could not decode image');
    }

    // Assuming model input size is 224x224 and input type is float32
    final int inputSize = 224;
    final img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    // Create a 4D list for input: [1, height, width, channels]
    final List<List<List<List<double>>>> input = List.generate(
      1,
      (i) => List.generate(
        inputSize,
        (j) => List.generate(
          inputSize,
          (k) => List.generate(3, (l) => 0.0),
        ),
      ),
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = (pixel.r - 127.5) / 127.5; // Normalize to [-1, 1]
        input[0][y][x][1] = (pixel.g - 127.5) / 127.5;
        input[0][y][x][2] = (pixel.b - 127.5) / 127.5;
      }
    }
    return input;
  }

  /// Classify a waste item from an image file
  Future<WasteItem> classifyImage(File imageFile) async {
    if (!_isModelLoaded) {
      await loadModel();
      if (!_isModelLoaded) {
        throw Exception('Model not loaded. Cannot classify image.');
      }
    }

    final input = _preprocessImage(imageFile);

    // Get the actual output shape from the interpreter
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final numClasses = outputShape[1]; // [1, numClasses]
    
    // Output tensor with correct shape from model
    final output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);

    // Run inference
    _interpreter!.run(input, output);

    // Process output to get probabilities
    final List<double> probabilities = (output[0] as List<double>);

    // Find the highest probability class
    int bestClassIndex = -1;
    double maxConfidence = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        bestClassIndex = i;
      }
    }

    if (bestClassIndex != -1 && _labels != null) {
      // Handle case where model has more classes than labels
      String predictedLabel;
      if (bestClassIndex < _labels!.length) {
        predictedLabel = _labels![bestClassIndex];
      } else {
        // Model has more classes than our labels file
        // Map to closest known category or use generic label
        print('Warning: Model output class $bestClassIndex exceeds label count ${_labels!.length}');
        predictedLabel = 'unknown_class_$bestClassIndex';
      }
      // You'll need to map your labels to WasteItem categories and details
      // This is a placeholder for actual mapping logic
      final wasteItem = WasteItem(
        id: 'waste_${DateTime.now().millisecondsSinceEpoch}',
        name: predictedLabel,
        category: _getCategoryFromLabel(predictedLabel), // Implement this mapping
        confidence: maxConfidence,
        disposalInstructions: _getDisposalInstructions(predictedLabel), // Implement this mapping
        tips: _getTips(predictedLabel), // Implement this mapping
        recyclable: _isRecyclable(predictedLabel), // Implement this mapping
        points: _getPoints(predictedLabel), // Implement this mapping
        imageUrl: imageFile.path,
        timestamp: DateTime.now(),
      );
      
      // Record scan in Firebase stats (async, don't await to avoid blocking UI)
      UserStatsService().recordScan(
        wasteType: predictedLabel,
        pointsEarned: wasteItem.points,
        carbonSaved: 0.5, // Average carbon saved per scan
      ).catchError((e) => print('Error recording stats: $e'));
      
      return wasteItem;
    } else {
      throw Exception('Classification failed or no confident prediction.');
    }
  }

  // Placeholder methods for mapping labels to WasteItem properties
  String _getCategoryFromLabel(String label) {
    // Handle unknown classes from model
    if (label.startsWith('unknown_class_')) return 'Unknown';
    
    // Normalize label to lowercase for matching
    final normalizedLabel = label.toLowerCase();
    
    // Map all 12 classes to categories
    switch (normalizedLabel) {
      case 'battery':
        return 'Hazardous';
      case 'biodegradable':
        return 'Organic';
      case 'cardboard':
        return 'Paper';
      case 'clothes':
        return 'Textile';
      case 'diapers':
        return 'Non-Recyclable';
      case 'ewaste':
      case 'e-waste':
        return 'Electronic';
      case 'glass':
        return 'Glass';
      case 'medical':
        return 'Hazardous';
      case 'metal':
        return 'Metal';
      case 'paper':
        return 'Paper';
      case 'plastic':
        return 'Plastic';
      case 'shoes':
        return 'Textile';
      default:
        return 'Unknown';
    }
  }

  String _getDisposalInstructions(String label) {
    final normalizedLabel = label.toLowerCase();
    
    switch (normalizedLabel) {
      case 'battery':
        return 'Take batteries to designated hazardous waste collection center or battery recycling drop-off. Never dispose in regular trash as they contain toxic chemicals.';
      case 'biodegradable':
        return 'Compost if possible or dispose in organic/green waste bin. Do not mix with recyclables.';
      case 'cardboard':
        return 'Flatten boxes to save space. Keep dry and clean. Remove any plastic tape or labels if required.';
      case 'clothes':
        return 'Donate if in good condition, or take to textile recycling center. Many charities accept clothing donations.';
      case 'diapers':
        return 'Dispose in regular trash. Cannot be recycled due to contamination. Consider using reusable cloth diapers as an eco-friendly alternative.';
      case 'ewaste':
      case 'e-waste':
        return 'Take to certified e-waste recycling facility. Contains valuable and hazardous materials. Never throw in regular trash.';
      case 'glass':
        return 'Rinse clean and remove lids. Glass can be recycled endlessly without loss of quality. Separate by color if required.';
      case 'medical':
        return 'Follow medical waste disposal guidelines. Sharps go in designated containers. Consult pharmacy or healthcare provider for proper disposal.';
      case 'metal':
        return 'Rinse clean and flatten if possible. Most metals are highly recyclable. Separate aluminum from steel if required.';
      case 'paper':
        return 'Keep dry and clean. Remove any plastic windows or metal fasteners. Shred sensitive documents before recycling.';
      case 'plastic':
        return 'Check for recycling symbols (1-7). Clean and dry before recycling. Remove caps and labels if required by your facility.';
      case 'shoes':
        return 'Donate if in good condition. Otherwise, check for shoe recycling programs. Some brands accept old shoes for recycling.';
      default:
        return 'Please check with your local waste management authority for proper disposal instructions.';
    }
  }

  List<String> _getTips(String label) {
    final normalizedLabel = label.toLowerCase();
    
    switch (normalizedLabel) {
      case 'battery':
        return ['Use rechargeable batteries to reduce waste', 'Store used batteries safely until disposal'];
      case 'biodegradable':
        return ['Start a home compost bin', 'Biodegradable waste can enrich soil'];
      case 'cardboard':
        return ['Reuse boxes for storage or moving', 'Cardboard makes great mulch for gardens'];
      case 'clothes':
        return ['Repair or upcycle old clothes', 'Buy quality items that last longer'];
      case 'diapers':
        return ['Consider cloth diapers as alternative', 'Choose eco-friendly biodegradable options'];
      case 'ewaste':
      case 'e-waste':
        return ['Repair electronics when possible', 'Extract data and erase before recycling'];
      case 'glass':
        return ['Reuse glass jars for storage', 'Glass is 100% recyclable'];
      case 'medical':
        return ['Never mix medical waste with regular trash', 'Check pharmacy take-back programs'];
      case 'metal':
        return ['Scrap metal has value—look for buyers', 'Aluminum cans save 95% energy when recycled'];
      case 'paper':
        return ['Print double-sided to save paper', 'Paper can be recycled 5-7 times'];
      case 'plastic':
        return ['Reduce single-use plastic consumption', 'Look for plastic-free alternatives'];
      case 'shoes':
        return ['Donate wearable shoes to those in need', 'Athletic brands often have recycling programs'];
      default:
        return ['Reduce, reuse, recycle', 'Check local recycling guidelines'];
    }
  }

  bool _isRecyclable(String label) {
    final normalizedLabel = label.toLowerCase();
    
    switch (normalizedLabel) {
      case 'battery':
      case 'biodegradable':
      case 'diapers':
      case 'medical':
        return false;
      case 'cardboard':
      case 'clothes':
      case 'ewaste':
      case 'e-waste':
      case 'glass':
      case 'metal':
      case 'paper':
      case 'plastic':
      case 'shoes':
        return true;
      default:
        return false;
    }
  }

  int _getPoints(String label) {
    final normalizedLabel = label.toLowerCase();
    
    // Points based on environmental impact and recycling value
    switch (normalizedLabel) {
      case 'battery':
        return 15; // High impact proper disposal
      case 'biodegradable':
        return 8;
      case 'cardboard':
        return 5;
      case 'clothes':
        return 10;
      case 'diapers':
        return 3; // Low but acknowledged
      case 'ewaste':
      case 'e-waste':
        return 20; // Highest due to complexity and value
      case 'glass':
        return 7;
      case 'medical':
        return 12; // Important safe disposal
      case 'metal':
        return 10;
      case 'paper':
        return 5;
      case 'plastic':
        return 6;
      case 'shoes':
        return 8;
      default:
        return 5;
    }
  }

  /// Get classification confidence threshold
  double get confidenceThreshold => 0.7;

  /// Check if classification confidence meets minimum threshold
  bool isConfidenceAcceptable(double confidence) {
    return confidence >= confidenceThreshold;
  }

  /// Get category-specific recycling guidelines
  Map<String, String> getCategoryGuidelines() {
    return {
      'Plastic': 'Check recycling symbols (1-7) and clean thoroughly before recycling.',
      'Metal': 'Most metals are highly recyclable. Clean and separate from other materials.',
      'Glass': 'Remove lids and labels. Glass can be recycled infinitely.',
      'Paper': 'Keep dry and clean. Remove any non-paper components.',
      'Organic': 'Compost when possible to reduce methane emissions from landfills.',
      'Electronic': 'Contains valuable materials but also hazardous substances. Use certified e-waste recyclers.',
      'Hazardous': 'Special handling required. Never put in regular trash or recycling.',
    };
  }

  /// Get points awarded for different waste categories
  Map<String, int> getCategoryPoints() {
    return {
      'Plastic': 5,
      'Metal': 3,
      'Glass': 4,
      'Paper': 3,
      'Organic': 2,
      'Electronic': 8,
      'Hazardous': 10,
    };
  }
}
