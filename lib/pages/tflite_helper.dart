import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math'; // Added this import for the max function

class TFLiteHelper {
  static const List<String> labels = [
    'actinic keratoses and intraepithelial carcinoma',
    'basal cell carcinoma',
    'benign keratosis',
    'dermatofibroma',
    'melanoma',
    'nevus',
    'vascular lesions'
  ];

  // Removed: static late String result;
  // Removed: String getResult() { return result; }

  static Future<String> classifyImage(File imageFile) async {
    // Load the model
    final interpreter = await Interpreter.fromAsset('lib/models/model_unquant.tflite');

    // Load and resize the image
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    // Ensure image is not null before proceeding
    if (image == null) {
      throw Exception("Failed to decode image from file.");
    }
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // Prepare the input tensor
    // Normalize pixel values to [0, 1]
    // The tflite model expects input in a specific format, often Float32List for images.
    // Let's create a Float32List directly for efficiency and correct type handling.
    var input = List.generate(1, (i) => List.generate(224, (j) => List.generate(224, (k) => List.filled(3, 0.0)))).cast<List<List<List<double>>>>();

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixelSafe(x, y);
        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }


    // Output buffer
    // The output shape from your model (7 classes)
    var output = List.filled(1 * 7, 0.0).reshape([1, 7]); // Reshape to [1, 7] for the output

    // Run inference
    interpreter.run(input, output);

    // Process the output
    // Ensure 'confidences' is explicitly treated as a List<double>
    final List<double> confidences = (output[0] as List).cast<double>();

    // Find the maximum confidence and its index
    final maxConfidence = confidences.reduce(max); // Using dart:math's max function
    final maxIdx = confidences.indexOf(maxConfidence); // Find the index of the max value

    // Format the result
    final confidence = (confidences[maxIdx] * 100).toStringAsFixed(2);

    // Release the interpreter resources
    interpreter.close();

    // Directly return the formatted string
    return "${labels[maxIdx]} ($confidence%)";
  }
}