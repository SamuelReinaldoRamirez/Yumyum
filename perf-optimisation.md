# Guide d'Optimisation des Performances de Yummap

## 1. Optimisation des Widgets

### 1.1 Utilisation de Widgets Const
```dart
// Avant
class CustomButton extends StatelessWidget {
  final String text;
  CustomButton({required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

// Après
class CustomButton extends StatelessWidget {
  final String text;
  const CustomButton({Key? key, required this.text}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
```

### 1.2 Widget Splitting
```dart
// Avant
class RestaurantList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) {
        return ComplexRestaurantTile();
      },
    );
  }
}

// Après
class RestaurantList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) {
        return const RestaurantTileHeader();  // Widget séparé
      },
    );
  }
}
```

## 2. Optimisation des Images

### 2.1 Lazy Loading
```dart
class OptimizedImageLoader {
  static Widget loadImage(String url, {double? width, double? height}) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      placeholder: (context, url) => const ShimmerPlaceholder(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      memCacheWidth: 800,  // Limite la taille en cache
      memCacheHeight: 800,
    );
  }
}
```

### 2.2 Image Caching
```dart
class ImageCache {
  static final Map<String, Uint8List> _cache = {};
  static const int maxSize = 50;  // Maximum d'images en cache
  
  static Future<Uint8List?> getImage(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    
    if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);  // FIFO
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      _cache[url] = response.bodyBytes;
      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }
}
```

## 3. Optimisation des Listes

### 3.1 Pagination
```dart
class PaginatedListView extends StatefulWidget {
  @override
  _PaginatedListViewState createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  static const int pageSize = 20;
  final List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  int _currentPage = 0;
  
  Future<void> _loadMore() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newRestaurants = await RestaurantService.getRestaurants(
        page: _currentPage,
        pageSize: pageSize,
      );
      
      setState(() {
        _restaurants.addAll(newRestaurants);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
}
```

### 3.2 Virtualisation
```dart
ListView.builder(
  itemCount: restaurants.length,
  cacheExtent: 500, // Cache plus d'éléments
  addAutomaticKeepAlives: false, // Désactive le keep alive automatique
  itemBuilder: (context, index) {
    return RestaurantTile(restaurant: restaurants[index]);
  },
)
```

## 4. Optimisation des Appels Réseau

### 4.1 Mise en Cache des Requêtes
```dart
class ApiCache {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration defaultTTL = Duration(minutes: 5);
  
  static Future<T?> getData<T>(
    String key,
    Future<T> Function() fetcher,
  ) async {
    if (_cache.containsKey(key) && !_cache[key]!.isExpired) {
      return _cache[key]!.data as T;
    }
    
    final data = await fetcher();
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
    
    return data;
  }
}
```

### 4.2 Batch Requests
```dart
class BatchRequestService {
  static final List<Future Function()> _queue = [];
  static Timer? _timer;
  
  static void addRequest(Future Function() request) {
    _queue.add(request);
    _scheduleProcessing();
  }
  
  static void _scheduleProcessing() {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 100), _processQueue);
  }
  
  static Future<void> _processQueue() async {
    final requests = List.from(_queue);
    _queue.clear();
    
    await Future.wait(
      requests.map((req) => req()),
    );
  }
}
```

## 5. Optimisation de l'État

### 5.1 Computed Properties
```dart
class RestaurantState extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  String _searchQuery = '';
  
  // Calcul optimisé avec mémorisation
  late final filteredRestaurants = computed(() {
    return _restaurants.where(
      (r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  });
}
```

## To-Do List pour l'Implémentation

### Phase 1 : Optimisation des Widgets
- [ ] Convertir les widgets statiques en const
- [ ] Implémenter le widget splitting
- [ ] Optimiser les rebuilds

### Phase 2 : Optimisation des Images
- [ ] Implémenter le lazy loading
- [ ] Mettre en place le système de cache d'images
- [ ] Optimiser la taille des images

### Phase 3 : Optimisation des Listes
- [ ] Implémenter la pagination
- [ ] Ajouter la virtualisation
- [ ] Optimiser le scroll

### Phase 4 : Optimisation Réseau
- [ ] Mettre en place le cache des requêtes
- [ ] Implémenter les batch requests
- [ ] Optimiser les payloads

### Phase 5 : Optimisation de l'État
- [ ] Implémenter les computed properties
- [ ] Optimiser les notifications d'état
- [ ] Mettre en place le state splitting

## État d'Avancement
- [ ] Phase 1 : 0%
- [ ] Phase 2 : 0%
- [ ] Phase 3 : 0%
- [ ] Phase 4 : 0%
- [ ] Phase 5 : 0%

## Métriques de Performance à Surveiller
1. Temps de démarrage de l'application
2. Temps de réponse des interactions utilisateur
3. Utilisation de la mémoire
4. Taux de rafraîchissement (FPS)
5. Temps de chargement des images
6. Temps de réponse des requêtes réseau

## Notes Importantes
1. Toujours mesurer avant et après les optimisations
2. Utiliser Flutter DevTools pour le profilage
3. Tester sur des appareils de basse gamme
4. Optimiser progressivement, une fonctionnalité à la fois
