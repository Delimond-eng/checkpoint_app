// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../modals/utils.dart';

class AppUpdateService {
  static const String _updateUrl =
      'http://192.168.32.247:8000/api/check.update';

  Timer? _periodicTimer;
  bool _isUpdating = false;

  /// Démarre la vérification périodique automatique.
  /// [onUpdateAvailable] : callback appelé si une maj est détectée.
  void startPeriodicCheck(Duration interval, Function() onUpdateAvailable) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (timer) async {
      if (_isUpdating) return;
      bool hasUpdate = await _hasUpdate();
      if (hasUpdate) {
        onUpdateAvailable();
      }
    });
  }

  /// Arrête la vérification périodique
  void stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Vérifie si une mise à jour est disponible (sans UI)
  Future<bool> _hasUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      int currentVersion = int.parse(packageInfo.buildNumber);

      final response = await Dio().get(_updateUrl);
      if (response.statusCode == 200) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;

        int latestVersion = data['version_code'];
        return latestVersion > currentVersion;
      }
    } catch (e) {
      debugPrint('Erreur vérification mise à jour: $e');
    }
    return false;
  }

  /// Vérifie et lance la mise à jour (avec UI et installation)
  Future<void> checkForUpdate(BuildContext context) async {
    if (_isUpdating) {
      return;
    }
    _isUpdating = true;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      int currentVersion = int.parse(packageInfo.buildNumber);

      final response = await Dio().get(_updateUrl);
      if (response.statusCode == 200) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;

        int latestVersion = data['version_code'];
        String apkUrl = data['apk_url'];
        String changelog = data['changelog'];

        if (latestVersion > currentVersion) {
          final confirm = await _showUpdateDialog(context, changelog);
          if (confirm) {
            await Future.delayed(const Duration(milliseconds: 300));
            final fixedUrl = apkUrl.replaceAll("127.0.0.1", "192.168.32.247");
            await _downloadAndInstallApk(context, fixedUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour: $e');
    } finally {
      _isUpdating = false;
    }
  }

  Future<bool> _showUpdateDialog(BuildContext context, String changelog) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Mise à jour disponible'),
            content: Text('Nouveautés :\n$changelog'),
            actions: [
              TextButton(
                child: const Text('Plus tard'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              ElevatedButton(
                child: const Text('Mettre à jour'),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _downloadAndInstallApk(
      BuildContext context, String apkUrl) async {
    try {
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/update.apk';

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      showCostumLoading(context);
      await Dio().download(apkUrl, filePath);
      await InstallPlugin.installApk(filePath,
          appId: 'com.example.checkpoint_app');
    } catch (e) {
      debugPrint("Erreur téléchargement ou installation APK: $e");
    } finally {
      Get.back(); // Ferme le loading s'il est encore ouvert
    }
  }
}
