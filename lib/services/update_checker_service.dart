import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseUrl,
  });

  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseUrl;
}

class UpdateCheckerService {
  const UpdateCheckerService({required this.owner, required this.repo});

  final String owner;
  final String repo;

  Future<UpdateCheckResult?> checkForUpdate() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final endpoint = Uri.parse(
        'https://api.github.com/repos/$owner/$repo/releases/latest',
      );
      final httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);
      final request = await httpClient.getUrl(endpoint);
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.github+json',
      );

      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final body = await utf8.decodeStream(response);
      final json = jsonDecode(body) as Map<String, dynamic>;

      final rawTag = (json['tag_name'] as String? ?? '').trim();
      final latestVersion = _normalizeVersion(rawTag);
      if (latestVersion.isEmpty) {
        return null;
      }

      final releaseUrl =
          _resolveAndroidAssetUrl(json) ??
          (json['html_url'] as String? ??
              'https://github.com/$owner/$repo/releases');

      return UpdateCheckResult(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        hasUpdate: _compareVersions(latestVersion, currentVersion) > 0,
        releaseUrl: releaseUrl,
      );
    } catch (_) {
      return null;
    }
  }

  String? _resolveAndroidAssetUrl(Map<String, dynamic> json) {
    final assets = (json['assets'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();

    final preferred = assets.firstWhere((asset) {
      final name = (asset['name'] as String? ?? '').toLowerCase();
      return name.contains('arm64-v8a') && name.endsWith('.apk');
    }, orElse: () => const <String, dynamic>{});

    if (preferred.isNotEmpty) {
      return preferred['browser_download_url'] as String?;
    }

    final anyApk = assets.firstWhere((asset) {
      final name = (asset['name'] as String? ?? '').toLowerCase();
      return name.endsWith('.apk');
    }, orElse: () => const <String, dynamic>{});

    if (anyApk.isNotEmpty) {
      return anyApk['browser_download_url'] as String?;
    }

    return null;
  }

  String _normalizeVersion(String raw) {
    final withoutPrefix = raw.startsWith('v') ? raw.substring(1) : raw;
    final match = RegExp(r'^(\d+)(\.\d+)?(\.\d+)?').firstMatch(withoutPrefix);
    return match?.group(0) ?? '';
  }

  int _compareVersions(String a, String b) {
    final aParts = _versionParts(a);
    final bParts = _versionParts(b);
    final length = aParts.length > bParts.length
        ? aParts.length
        : bParts.length;

    for (var i = 0; i < length; i++) {
      final aPart = i < aParts.length ? aParts[i] : 0;
      final bPart = i < bParts.length ? bParts[i] : 0;
      if (aPart > bPart) {
        return 1;
      }
      if (aPart < bPart) {
        return -1;
      }
    }
    return 0;
  }

  List<int> _versionParts(String version) {
    return version
        .split('.')
        .map((segment) => int.tryParse(segment) ?? 0)
        .toList();
  }
}
