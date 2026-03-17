import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../../l10n/s.dart';

abstract class ImageCompressionStrategy {
  const ImageCompressionStrategy();

  bool get canEdit;
  bool get supportsCompression;

  String get displayName;

  int estimateCompressedSize(int originalSize, int quality);

  Future<String> compress(String sourcePath, int quality);
}

class GifImageCompressionStrategy extends ImageCompressionStrategy {
  GifImageCompressionStrategy();

  @override
  bool get canEdit => false;

  @override
  bool get supportsCompression => false;

  @override
  String get displayName => S.current.imageFormat_gif;

  @override
  int estimateCompressedSize(int originalSize, int quality) => originalSize;

  @override
  Future<String> compress(String sourcePath, int quality) async => sourcePath;
}

class PassthroughImageCompressionStrategy extends ImageCompressionStrategy {
  const PassthroughImageCompressionStrategy({required this.displayName});

  @override
  final String displayName;

  @override
  bool get canEdit => true;

  @override
  bool get supportsCompression => false;

  @override
  int estimateCompressedSize(int originalSize, int quality) => originalSize;

  @override
  Future<String> compress(String sourcePath, int quality) async => sourcePath;
}

class StaticImageCompressionStrategy extends ImageCompressionStrategy {
  const StaticImageCompressionStrategy({
    required this.displayName,
    required this.format,
    required this.extension,
  });

  @override
  final String displayName;
  final CompressFormat format;
  final String extension;

  @override
  bool get canEdit => true;

  @override
  bool get supportsCompression => true;

  @override
  int estimateCompressedSize(int originalSize, int quality) {
    final ratio = quality / 100.0;
    return (originalSize * ratio * ratio).round();
  }

  @override
  Future<String> compress(String sourcePath, int quality) async {
    if (quality >= 100) {
      return sourcePath;
    }

    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(
      tempDir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: quality,
      minWidth: 1920,
      minHeight: 1920,
      format: format,
    );

    return result?.path ?? sourcePath;
  }
}

class ImageCompressionStrategyFactory {
  static ImageCompressionStrategy fromPath(String path) {
    switch (p.extension(path).toLowerCase()) {
      case '.gif':
        return GifImageCompressionStrategy();
      case '.png':
        return StaticImageCompressionStrategy(
          displayName: S.current.imageFormat_png,
          format: CompressFormat.png,
          extension: 'png',
        );
      case '.webp':
        return StaticImageCompressionStrategy(
          displayName: S.current.imageFormat_webp,
          format: CompressFormat.webp,
          extension: 'webp',
        );
      case '.jpg':
      case '.jpeg':
        return StaticImageCompressionStrategy(
          displayName: S.current.imageFormat_jpeg,
          format: CompressFormat.jpeg,
          extension: 'jpg',
        );
      default:
        return PassthroughImageCompressionStrategy(displayName: S.current.imageFormat_generic);
    }
  }
}
