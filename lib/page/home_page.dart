import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummap/page/explore_page.dart';
import 'package:yummap/services/cache_manager.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/helper/map_helper.dart';

class HomePage extends StatefulWidget {
  final int? followedWorkspaceId;  

  const HomePage({
    super.key,
    this.followedWorkspaceId,  
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String cacheKey = 'restaurants';
  final ValueNotifier<double> _loadingProgress = ValueNotifier<double>(0.0);
  bool _isLoading = false;
  late Future<Map<String, dynamic>> _preloadedData;
  int? followedWorkspaceId; 

  @override
  void initState() {
    super.initState();
    followedWorkspaceId = widget.followedWorkspaceId; 
    // Démarrer le préchargement immédiatement
    _preloadedData = _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(context),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/illustrations/Baker-pana.svg',
              width: 300,
            ),
            const SizedBox(height: 32),
            Text(
              'Yummap',
              style: AppTextStyles.titleBlackStyle,
            ),
            const SizedBox(height: 16),
            Text(
              'Retrouvez en un instant les meilleurs endroits \npour savourer vos moments gourmands avec Yummap.',
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraphDarkStyle,
            ),
            const SizedBox(height: 82),
            CustomNeuButton(
              text: 'Continuer',
              icon: Icons.arrow_forward,
              buttonColor: AppColors.appSecondary,
              textColor: Colors.white,
              onPressed: _handleContinuePressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _loadingProgress,
              builder: (context, progress, _) {
                return Column(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.appSecondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement ${(progress * 100).toInt()}%',
                      style: AppTextStyles.paragraphDarkStyle
                          .copyWith(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _initializeApp() async {
    try {
      _loadingProgress.value = 0.1;
      final restaurants = await _getRestaurants();

      _loadingProgress.value = 0.4;
      final preloadedData = await _preloadResources(restaurants);

      _loadingProgress.value = 0.8;
      final notifiers = _initializeNotifiers();

      _loadingProgress.value = 1.0;

      return {
        ...preloadedData,
        ...notifiers,
      };
    } catch (e) {
      print('Erreur d\'initialisation: $e');
      throw Exception('Erreur lors du chargement de l\'application');
    }
  }

  Future<void> _handleContinuePressed() async {
    setState(() => _isLoading = true);
    try {
      final data = await _preloadedData;
      if (!mounted) return;
      
      // Si nous avons un workspace à pré-sélectionner
      final workspaceId = followedWorkspaceId;  
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            print("Navigation vers ExplorePage avec workspaceId: $workspaceId");
            return ExplorePage(
              restaurantList: data['restaurants'],
              selectedTagIdsNotifier: data['selectedTagIdsNotifier'],
              selectedWorkspacesNotifier: data['selectedWorkspacesNotifier'],
              ratingFilterNotifier: ValueNotifier<bool>(false),
              filterFavoritesNotifier: ValueNotifier<bool>(false),
              filterIsOn: ValueNotifier<bool>(false),
              preSelectedWorkspaceId: workspaceId?.toString(),  
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue: ${e.toString()}'),
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: _handleContinuePressed,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Restaurant>> _getRestaurants() async {
    final cache = CacheManager();
    try {
      final cachedData = cache.get<List<Restaurant>>(cacheKey);
      if (cachedData != null) {
        _refreshDataInBackground(cache);
        return cachedData;
      }
    } catch (e) {
      print('Erreur de cache: $e');
    }
    final restaurants = await CallEndpointService().getRestaurantsFromXanos();
    cache.set(cacheKey, restaurants, ttl: const Duration(minutes: 15));
    return restaurants;
  }

  Future<void> _refreshDataInBackground(CacheManager cache) async {
    try {
      final freshData = await CallEndpointService().getRestaurantsFromXanos();
      cache.set(cacheKey, freshData, ttl: const Duration(minutes: 15));
    } catch (e) {
      print('Erreur de rafraîchissement: $e');
    }
  }

  Future<Map<String, dynamic>> _preloadResources(
      List<Restaurant> restaurants) async {
    final markers = await MapHelper.createMarkersFromRestaurants(restaurants);
    MarkerManager.swapMarkersList(markers);
    MarkerManager.allmarkers = List<Marker>.from(markers);
    final cuisines = restaurants.map((r) => r.cuisine).toSet().toList();
    return {
      'restaurants': restaurants,
      'markers': markers,
      'cuisines': cuisines,
    };
  }

  Map<String, dynamic> _initializeNotifiers() {
    return {
      'selectedTagIdsNotifier': ValueNotifier<List<int>>([]),
      'selectedWorkspacesNotifier': ValueNotifier<List<int>>([]),
    };
  }

  @override
  void dispose() {
    _loadingProgress.dispose();
    super.dispose();
  }
}
