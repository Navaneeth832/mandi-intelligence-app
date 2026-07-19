import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

class CommodityImageWidget extends StatelessWidget {
  final String? imageUrl;
  final int? commodityId;
  final double height;
  final double width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CommodityImageWidget({
    super.key,
    this.imageUrl,
    this.commodityId,
    this.height = 160,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  static const String defaultFarmImage =
      "https://farm.ws/wp-content/uploads/2024/11/What-is-Crop-Farming_-Everything-You-Need-to-Know-930x620.webp";

  @override
  Widget build(BuildContext context) {
    String? rawUrl = imageUrl;
    if ((rawUrl == null || rawUrl.isEmpty) && commodityId != null) {
      rawUrl = "/static/commodity-images/$commodityId.jpeg";
    }

    String targetImageUrl;
    if (rawUrl == null || rawUrl.isEmpty) {
      targetImageUrl = defaultFarmImage;
    } else if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      targetImageUrl = rawUrl;
    } else {
      final String base = ApiConstants.baseUrl.endsWith('/')
          ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
          : ApiConstants.baseUrl;
      final String path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
      targetImageUrl = '$base$path';
    }

    Widget imageWidget = Image.network(
      targetImageUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          defaultFarmImage,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: height,
              width: width,
              color: const Color(0xFFE2E8F0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: height > 60 ? 44 : 24,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }
}
