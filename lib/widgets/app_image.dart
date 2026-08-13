import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders a local asset OR a remote URL with caching, placeholder, and
/// error fallback — use everywhere instead of bare Image.asset / Image.network.
class AppImage extends StatelessWidget {
  final String src;
  final BoxFit fit;
  final Color? fallbackColor;
  final IconData fallbackIcon;

  const AppImage({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    this.fallbackColor,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  bool get _isLocal => src.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (_isLocal) {
      return Image.asset(src, fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: src,
      fit: fit,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ),
      );

  Widget _fallback() => Container(
        color: (fallbackColor ?? Colors.grey).withValues(alpha: 0.12),
        child: Center(
          child: Icon(
            fallbackIcon,
            color: (fallbackColor ?? Colors.grey).withValues(alpha: 0.5),
            size: 32,
          ),
        ),
      );
}
