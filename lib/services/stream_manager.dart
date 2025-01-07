import 'dart:async';

class StreamManager {
  // Singleton pattern
  static final StreamManager _instance = StreamManager._internal();
  factory StreamManager() => _instance;
  StreamManager._internal();

  // Map pour stocker tous les StreamSubscriptions
  final Map<String, StreamSubscription> _subscriptions = {};
  
  // Map pour stocker les métadonnées des streams
  final Map<String, StreamMetadata> _metadata = {};

  // Ajouter une subscription
  void addSubscription(
    String key, 
    StreamSubscription subscription, {
    String? description,
    Duration? timeout,
  }) {
    // Annuler l'ancienne subscription si elle existe
    cancelSubscription(key);
    
    _subscriptions[key] = subscription;
    _metadata[key] = StreamMetadata(
      createdAt: DateTime.now(),
      description: description,
      timeout: timeout,
    );

    // Configurer un timeout si spécifié
    if (timeout != null) {
      Future.delayed(timeout, () => checkAndCancelTimeout(key));
    }
  }

  // Annuler une subscription spécifique
  void cancelSubscription(String key) {
    _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
    _metadata.remove(key);
  }

  // Vérifier et annuler si le timeout est dépassé
  void checkAndCancelTimeout(String key) {
    final metadata = _metadata[key];
    if (metadata == null) return;

    if (metadata.timeout != null &&
        DateTime.now().difference(metadata.createdAt) >= metadata.timeout!) {
      cancelSubscription(key);
    }
  }

  // Annuler toutes les subscriptions
  void dispose() {
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _metadata.clear();
  }

  // Obtenir des statistiques sur les streams actifs
  Map<String, StreamStats> getStats() {
    final stats = <String, StreamStats>{};
    
    for (var entry in _subscriptions.entries) {
      final metadata = _metadata[entry.key];
      stats[entry.key] = StreamStats(
        isActive: true,
        createdAt: metadata?.createdAt ?? DateTime.now(),
        description: metadata?.description,
        timeout: metadata?.timeout,
      );
    }
    
    return stats;
  }
}

// Classe pour stocker les métadonnées des streams
class StreamMetadata {
  final DateTime createdAt;
  final String? description;
  final Duration? timeout;

  StreamMetadata({
    required this.createdAt,
    this.description,
    this.timeout,
  });
}

// Classe pour les statistiques des streams
class StreamStats {
  final bool isActive;
  final DateTime createdAt;
  final String? description;
  final Duration? timeout;

  StreamStats({
    required this.isActive,
    required this.createdAt,
    this.description,
    this.timeout,
  });

  @override
  String toString() {
    return 'StreamStats(active: $isActive, created: $createdAt, desc: $description)';
  }
}
