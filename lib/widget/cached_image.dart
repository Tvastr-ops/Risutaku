import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:risutaku/extension/snack_bar_extension.dart';

/// A custom cache manager is needed to define exact image cap and stale period.
final _cacheManager = CacheManager(
  Config('imageCache', maxNrOfCacheObjects: 1000, stalePeriod: const Duration(days: 10)),
);

/// Erases image cache.
void clearImageCache() {
  _cacheManager.emptyCache();
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
}

/// A [CachedNetworkImage] wrapper that simplifies the interface
/// and uses the custom cache manager, without exposing it.
class CachedImage extends StatelessWidget {
  const CachedImage(
    this.imageUrl, {
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
    this.memCacheWidth,
    this.memCacheHeight,
    this.downscale = true,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final bool downscale;

  @override
  Widget build(BuildContext context) {
    final int? targetMemWidth;
    if (!downscale) {
      targetMemWidth = null;
    } else if (memCacheWidth != null) {
      targetMemWidth = memCacheWidth;
    } else if (width == null && height == null) {
      targetMemWidth = null;
    } else if (width != null && width! > 0 && width != double.infinity) {
      targetMemWidth = (width! * 3).round().clamp(150, 720);
    } else {
      targetMemWidth = 450;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: targetMemWidth,
      memCacheHeight: memCacheHeight,
      cacheManager: _cacheManager,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      errorWidget: (context, _, _) => IconButton(
        tooltip: 'Error',
        icon: const Icon(Icons.close_outlined),
        onPressed: () => SnackBarExtension.show(context, 'Failed to load image'),
      ),
    );
  }
}
