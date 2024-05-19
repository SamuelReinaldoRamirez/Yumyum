import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';

class TrackingStatusDialog {
  static Future<void> requestAppTrackingAuthorization(context) async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    switch (status) {
      case TrackingStatus.notDetermined:
        // L'autorisation de suivi n'a pas encore été demandée.
        await _showTrackingDialog(context);
        break;
      case TrackingStatus.restricted:
        // L'utilisateur a restreint le suivi sur cet appareil.
        break;
      case TrackingStatus.denied:
        // L'utilisateur a refusé le suivi sur cet appareil.
        break;
      case TrackingStatus.authorized:
        // L'utilisateur a autorisé le suivi sur cet appareil.
        break;
      case TrackingStatus.notSupported:
        //
        break;
    }
  }

  static Future<void> _showTrackingDialog(context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autoriser le suivi'),
        content: const Text(
          'Voulez-vous autoriser cette application à suivre votre activité pour des raisons publicitaires ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestSystemTrackingAuthorization();
            },
            child: const Text('Autoriser'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleTrackingDenied();
            },
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  static Future<void> _requestSystemTrackingAuthorization() async {
    final TrackingStatus status =
        await AppTrackingTransparency.requestTrackingAuthorization();
    switch (status) {
      case TrackingStatus.authorized:
        // L'utilisateur a autorisé le suivi sur cet appareil.
        break;
      case TrackingStatus.denied:
        // L'utilisateur a refusé le suivi sur cet appareil.
        break;
      default:
        // Gérer les autres cas si nécessaire.
        break;
    }
  }

  static void _handleTrackingDenied() {
    // Actions à entreprendre si l'utilisateur refuse le suivi.
  }
}
