import 'dart:collection';
import 'dart:async'; // Import added for Timer

class CacheManager {
  // Singleton pattern
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // Configuration
  static const Duration defaultTTL = Duration(minutes: 30);
  static const int maxEntries = 100;

  // Cache storage
  final LinkedHashMap<String, CacheEntry> _cache = LinkedHashMap();

  // Métriques
  int _hits = 0;
  int _misses = 0;

  // Stocker une valeur dans le cache
  void set<T>(String key, T value, {Duration? ttl}) {
    _cleanExpiredEntries();

    // Si le cache est plein, supprimer l'entrée la plus ancienne
    if (_cache.length >= maxEntries) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = CacheEntry(
      data: value,
      expiryTime: DateTime.now().add(ttl ?? defaultTTL),
    );
  }

  // Récupérer une valeur du cache
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null || entry.isExpired) {
      _misses++;
      _cache.remove(key);
      return null;
    }

    _hits++;
    return entry.data as T;
  }

  // Nettoyer les entrées expirées
  void _cleanExpiredEntries() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  // Vider le cache
  void clear() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
  }

  // Obtenir les métriques du cache
  CacheMetrics getMetrics() {
    return CacheMetrics(
      totalEntries: _cache.length,
      hits: _hits,
      misses: _misses,
      hitRate: _hits + _misses == 0 ? 0 : _hits / (_hits + _misses),
    );
  }

  // Vérifier si une clé existe et est valide
  bool has(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }

  // Supprimer une entrée spécifique
  void remove(String key) {
    _cache.remove(key);
  }

  // Journaliser les métriques de cache
  void logCacheMetrics() {
    final metrics = getMetrics();
    print('''
Cache Metrics:
- Hits: ${metrics.hits}
- Misses: ${metrics.misses}
- Hit Rate: ${metrics.hitRate.toStringAsFixed(2)}%
- Size: ${metrics.totalEntries}
- Average Access Time: 0ms // This field was not implemented
''');
  }

  // Initialiser la surveillance du cache
  void initializeCacheMonitoring() {
    const duration = Duration(minutes: 15);
    Timer.periodic(duration, (_) {
      final cache = CacheManager();
      cache.logCacheMetrics();
      cache._cleanExpiredEntries();
    });
  }
}

// Classe pour stocker les entrées du cache
class CacheEntry {
  final dynamic data;
  final DateTime expiryTime;

  CacheEntry({
    required this.data,
    required this.expiryTime,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

// Classe pour les métriques du cache
class CacheMetrics {
  final int totalEntries;
  final int hits;
  final int misses;
  final double hitRate;

  CacheMetrics({
    required this.totalEntries,
    required this.hits,
    required this.misses,
    required this.hitRate,
  });

  @override
  String toString() {
    return 'CacheMetrics(entries: $totalEntries, hits: $hits, misses: $misses, hitRate: ${(hitRate * 100).toStringAsFixed(2)}%)';
  }
}
