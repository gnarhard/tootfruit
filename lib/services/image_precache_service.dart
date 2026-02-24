import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImagePrecacheService {
  final Future<List<String>> Function() _fruitAssetResolver;
  final Future<void> Function(BuildContext context, String assetPath)
  _rasterPrecache;
  final Future<void> Function(String assetPath) _svgPrecache;

  ImagePrecacheService({
    Future<List<String>> Function()? fruitAssetResolver,
    Future<void> Function(BuildContext context, String assetPath)?
    rasterPrecache,
    Future<void> Function(String assetPath)? svgPrecache,
  }) : _fruitAssetResolver =
           fruitAssetResolver ?? _resolveFruitAssetsFromManifest,
       _rasterPrecache = rasterPrecache ?? _precacheRasterAsset,
       _svgPrecache = svgPrecache ?? _precacheSvgAsset;

  static const List<String> tootFairyRasterAssets = [
    'assets/images/all_fruits.png',
    'assets/images/clouds_bottom_smaller.png',
    'assets/images/clouds_top_smaller.png',
    'assets/images/cloud_simple.png',
    'assets/images/toot_fairy.png',
  ];

  Future<void> precacheLaunchImages(BuildContext context) async {
    await Future.wait([
      for (final assetPath in tootFairyRasterAssets)
        _rasterPrecache(context, assetPath),
    ]);

    final fruitSvgAssets = await _fruitAssetResolver();
    await Future.wait([
      for (final assetPath in fruitSvgAssets) _svgPrecache(assetPath),
    ]);
  }

  static Future<List<String>> _resolveFruitAssetsFromManifest() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final fruitSvgAssets = manifest.listAssets().where((assetPath) {
      return assetPath.startsWith('assets/images/fruit/') &&
          assetPath.endsWith('.svg');
    }).toList()..sort();
    return fruitSvgAssets;
  }

  static Future<void> _precacheRasterAsset(
    BuildContext context,
    String assetPath,
  ) {
    return precacheImage(AssetImage(assetPath), context);
  }

  static Future<void> _precacheSvgAsset(String assetPath) {
    final loader = SvgAssetLoader(assetPath);
    return loader.loadBytes(null);
  }
}
