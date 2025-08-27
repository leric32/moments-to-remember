import 'dart:convert';
import 'package:flutter/material.dart';

/// A universal image widget that handles network, asset, and base64 images
class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = _buildImage();

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildImage() {
    // Handle base64 images
    if (imageUrl.startsWith('base64:')) {
      try {
        final base64String = imageUrl.substring(7); // Remove 'base64:' prefix
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } catch (e) {
        return _buildErrorWidget();
      }
    }

    // Handle asset images
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    // Handle network images
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 8),
            Text(
              'Učitava...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: width != null ? width! * 0.3 : 32,
              color: Colors.white,
            ),
            if (width == null || width! > 100) ...[
              const SizedBox(height: 8),
              Text(
                'Događaj',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width != null ? width! * 0.1 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
