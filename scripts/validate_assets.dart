import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

void main() async {
  print('Starting asset validation...');

  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('Error: pubspec.yaml not found.');
    exit(1);
  }

  final pubspecContent = await pubspecFile.readAsString();
  final pubspecYaml = loadYaml(pubspecContent);

  final flutterSection = pubspecYaml['flutter'];
  if (flutterSection == null || flutterSection['assets'] == null) {
    print('No assets section found in pubspec.yaml. Skipping asset validation.');
    exit(0);
  }

  final assets = List<String>.from(flutterSection['assets'] as YamlList);
  bool allAssetsValid = true;

  for (var assetPath in assets) {
    if (assetPath is String) {
      if (assetPath.endsWith('/')) {
        // It's a directory, check if it exists
        final directory = Directory(assetPath);
        if (!await directory.exists()) {
          print('Error: Asset directory not found: $assetPath');
          allAssetsValid = false;
        } else {
          print('Validated asset directory: $assetPath');
        }
      } else {
        // It's a file, check if it exists
        final file = File(assetPath);
        if (!await file.exists()) {
          print('Error: Asset file not found: $assetPath');
          allAssetsValid = false;
        } else {
          print('Validated asset file: $assetPath');
        }
      }
    }
  }

  if (allAssetsValid) {
    print('All assets listed in pubspec.yaml are valid.');
    exit(0);
  } else {
    print('Asset validation failed: Some assets are missing or invalid.');
    exit(1);
  }
}