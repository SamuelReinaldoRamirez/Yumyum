import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageOptimizer {
  static final ImageOptimizer _instance = ImageOptimizer._internal();
  factory ImageOptimizer() => _instance;
  ImageOptimizer._internal();

  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const String cacheKey = 'optimized_images';

  // Cache manager personnalisé pour les images
  final imageCacheManager = CacheManager(
    Config(
      cacheKey,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  // Optimiser et mettre en cache une image
  Future<String?> optimizeAndCacheImage(String imageUrl) async {
    try {
      // Vérifier si l'image est déjà en cache
      final cachedFile = await imageCacheManager.getFileFromCache(imageUrl);
      if (cachedFile != null) {
        return cachedFile.file.path;
      }

      // Télécharger et optimiser l'image
      final file = await imageCacheManager.downloadFile(imageUrl);
      final optimizedPath = await _optimizeImage(file.file);
      
      return optimizedPath;
    } catch (e) {
      print('Erreur lors de l\'optimisation de l\'image: $e');
      return null;
    }
  }

  // Méthode pour optimiser l'image
  Future<String> _optimizeImage(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final optimizedFile = File(
      '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Exemple de redimensionnement d'image
    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    final optimizedImage = img.copyResize(originalImage!, width: maxWidth, height: maxHeight);

    await optimizedFile.writeAsBytes(
      img.encodeJpg(optimizedImage, quality: 85),
    );

    return optimizedFile.path; // Retournez le chemin de l'image optimisée
  }

  // Ajout de la méthode optimizedImage
  Widget optimizedImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return FutureBuilder<String?>(
      future: optimizeAndCacheImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return OptimizedImage(
            imageFile: File(snapshot.data!),
            width: width,
            height: height,
            fit: fit,
          );
        }
        // Afficher un placeholder pendant le chargement
        return ImagePlaceholder(
          width: width,
          height: height,
        );
      },
    );
  }

  Future<void> clearImageCache() async {
    await imageCacheManager.emptyCache();
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> reinitializeCache() async {
    // Réinitialiser le cache si nécessaire
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class OptimizedImage extends StatelessWidget {
  const OptimizedImage({super.key, required this.imageFile, this.width, this.height, this.fit});

  final File imageFile;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      imageFile,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
    );
  }
}
