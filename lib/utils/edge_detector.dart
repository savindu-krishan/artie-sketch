import 'dart:typed_data';
import 'package:image/image.dart' as img;

class EdgeDetector {
  /// Params for Isolate computation
  static Uint8List process(Map<String, dynamic> params) {
    final Uint8List bytes = params['bytes'];
    final int threshold = params['threshold'];
    final int strokeColor = params['color']; // Hex integer e.g., 0xFF3B30
    
    return detectEdges(bytes, threshold, strokeColor);
  }

  static Uint8List detectEdges(Uint8List imageBytes, int threshold, int strokeColorHex) {
    // Decode image
    final original = img.decodeImage(imageBytes);
    if (original == null) return imageBytes;

    final width = original.width;
    final height = original.height;

    // Create blank transparent image for outline
    final output = img.Image(width: width, height: height, numChannels: 4);

    // Extract color parts
    final rColor = (strokeColorHex >> 16) & 0xFF;
    final gColor = (strokeColorHex >> 8) & 0xFF;
    final bColor = strokeColorHex & 0xFF;

    // Precompute threshold square to avoid sqrt
    final double thresholdSq = (threshold * 3.0) * (threshold * 3.0);

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Central pixel luminance
        final cPixel = original.getPixel(x, y);
        final double cLuma = 0.299 * cPixel.r + 0.587 * cPixel.g + 0.114 * cPixel.b;

        // Right pixel luminance
        final rPixel = original.getPixel(x + 1, y);
        final double rLuma = 0.299 * rPixel.r + 0.587 * rPixel.g + 0.114 * rPixel.b;

        // Bottom pixel luminance
        final bPixel = original.getPixel(x, y + 1);
        final double bLuma = 0.299 * bPixel.r + 0.587 * bPixel.g + 0.114 * bPixel.b;

        // Compute local gradient differences
        final double dx = rLuma - cLuma;
        final double dy = bLuma - cLuma;
        final double gradientSq = (dx * dx) + (dy * dy);

        if (gradientSq > thresholdSq) {
          // Draw solid outline pixel
          output.setPixelRgba(x, y, rColor, gColor, bColor, 255);
        } else {
          // Transparent background
          output.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    // Encode result back as a PNG
    return Uint8List.fromList(img.encodePng(output));
  }
}
