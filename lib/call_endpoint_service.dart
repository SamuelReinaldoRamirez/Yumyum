import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/review.dart';
import 'package:yummap/workspace.dart';
import 'package:yummap/tag.dart';

class CallEndpointService {
  // Instance unique de la classe
  static final CallEndpointService _instance = CallEndpointService._internal();
  static var logger = Logger();


  // Constructeur privé
  CallEndpointService._internal() {
    init();
  }

  // Méthode factory pour retourner l'instance
  factory CallEndpointService() {
    return _instance;
  }

  // Variables d'instance pour les URL de base
  static String rootUrl = "";
  static String baseUrl = "";
  static String allTagsUrl = "";

  // Méthode pour initialiser les variables
  void init() {
    //on devrait regarder les prefs de l'utilisateur pour savoir s'il est en prod ou en dev avant de setter
    rootUrl = "https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX";
    baseUrl = rootUrl + '/restaurants';
    allTagsUrl = rootUrl + '/tags';
  }

    // Méthode pour changer l'URL en fonction de l'environnement
  static Future<void> switchToEnv(String envId) async {
    final String endpoint = rootUrl + "/env/$envId";

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        rootUrl = jsonData['xano_endpoint'];
        baseUrl = rootUrl + '/restaurants';
        allTagsUrl = rootUrl + '/tags';
        // logger.d("Switched to environment: $envId, rootUrl: $rootUrl");
      } else {
        throw Exception('Failed to switch environment');
      }
    } catch (e) {
      throw Exception('Failed to switch environment: $e');
    }
  }

  static Future<void> switchToProd() async {
    print("TOPROD");
    await switchToEnv('2');
  }

  static Future<void> switchToDev() async {
    print("TODEV");
    await switchToEnv('1');
  }

  Future<List<Restaurant>> getRestaurantsFromXanos() async {
    if (baseUrl.isEmpty) {
      throw Exception('Service not initialized. Call init() first.');
    }
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Restaurant> restaurants = jsonData.map((data) {
          return Restaurant.fromJson(data);
        }).toList();

        return restaurants;
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      throw Exception('Failed to load restaurants: $e');
    }
  }

  Future<List<Tag>> getTagsFromXanos() async {
    if (allTagsUrl.isEmpty) {
      throw Exception('Service not initialized. Call init() first.');
    }

    try {
      final response = await http.get(Uri.parse(allTagsUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Tag> tags = jsonData.map((data) {
          return Tag.fromJson(data);
        }).toList();

        return tags;
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (e) {
      throw Exception('Failed to load tags: $e');
    }
  }

  Future<List<Review>> getReviewsByRestaurantAndWorkspaces(int restaurant_id, List<int> workspace_ids) async {
    final String url = '$rootUrl/review/restaurant/workspaces/$restaurant_id';
    try {
      // Préparation du corps de la requête
      final Map<String, List<int>> body = {
        'workspaces_ids': workspace_ids,
      };

      // Envoi de la requête POST
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Vérification du statut de la réponse
      if (response.statusCode == 200) {
        // Décodage de la réponse JSON en liste
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Review> reviews = jsonData.map((data) => Review.fromJson(data)).toList();

        return reviews;
      } else {
        // Gestion de l'erreur si la requête a échoué
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      // Gestion de toute autre exception
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<List> getWorkspaceIdsByAliases(List<String> aliasList) async {
  final String url = '$rootUrl/workspace/byAlias';

    try {
      // Préparation du corps de la requête
      final Map<String, List<String>> body = {
        'alias_list': aliasList,
      };

      // Envoi de la requête POST
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Vérification du statut de la réponse
      if (response.statusCode == 200) {
        // Décodage de la réponse JSON en liste
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        // Gestion de l'erreur si la requête a échoué
        throw Exception('Failed to load workspaces from alias');
      }
    } catch (e) {
      // Gestion de toute autre exception
      throw Exception('Failed to load workspaces from alias: $e');
    }
  }


  Future<List<Restaurant>> getRestaurantsByTagsAndWorkspaces(
      List<int> tagsId, List<int> workspaceIds) async {
    
    if (baseUrl.isEmpty) {
      throw Exception('Service not initialized. Call init() first.');
    }

    // Créer le corps de la requête avec tags_id et workspace_ids
    String requestBody = jsonEncode({
      'tags_id': tagsId,
      'workspace_ids': workspaceIds,
    });

    String url = '$baseUrl/tagsAndWorkspaces';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody, 
      );
      if (response.statusCode == 200) {
        // Décoder la réponse JSON
        final dynamic jsonData = json.decode(response.body);
        // Accéder à la clé "restaurants1" pour obtenir la liste des restaurants
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('restaurants1')) {
          List<dynamic> restaurantList = jsonData['restaurants1'];
          // Convertir chaque élément de la liste en un objet Restaurant
          List<Restaurant> restaurants = restaurantList.map((data) {
            return Restaurant.fromJson(data);
          }).toList();
          return restaurants;
        } else {
          throw Exception('Expected a Map with key "restaurants1", but received a different type');
        }
      } else {
        throw Exception('Failed to load restaurants by tags and workspaces');
      }
    } catch (e) {
      throw Exception('Failed to load restaurants by tags and workspaces: $e');
    }
  }

//AVANT DE SUPPRIMER : SUPPRIME LE ENDPOINT DANS XANO
  // Future<List<Restaurant>> getRestaurantsByTags(List<int> tagsId) async {
  //   if (baseUrl.isEmpty) {
  //     throw Exception('Service not initialized. Call init() first.');
  //   }

  //   String tagsIdQueryString = jsonEncode({'tags_id': tagsId});

  //   String url = '$baseUrl/tags/';

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: tagsIdQueryString,
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = json.decode(response.body);

  //       List<Restaurant> restaurants = jsonData.map((data) {
  //         return Restaurant.fromJson(data);
  //       }).toList();

  //       return restaurants;
  //     } else {
  //       throw Exception('Failed to load restaurants by tags');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load restaurants by tags: $e');
  //   }
  // }

  Future<List<Restaurant>> searchRestaurantByName(String restaurantName) async {
    if (rootUrl.isEmpty) {
      throw Exception('Service not initialized. Call init() first.');
    }

    final String endpoint = '$rootUrl/restaurants/search/$restaurantName';

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Restaurant> restaurants = jsonData.map((data) {
          return Restaurant.fromJson(data);
        }).toList();

        return restaurants;
      } else {
        throw Exception('Failed to search restaurants by name');
      }
    } catch (e) {
      throw Exception('Failed to search restaurants by name: $e');
    }
  }

  Future<List<Workspace>> searchWorkspaceByName(String workspaceName) async {
    if (rootUrl.isEmpty) {
      throw Exception('Service not initialized. Call init() first.');
    }
    final String endpoint = '$rootUrl/workspace/search/$workspaceName';
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Workspace> workspaces = jsonData.map((data) {
          return Workspace.fromJson(data);
        }).toList();
        return workspaces;
      } else {
        throw Exception('Failed to search workspace by name');
      }
    } catch (e) {
      throw Exception('Failed to search workspace by name: $e');
    }
  }

//AVANT DE SUPPRIMER : SUPRIME LE ENDPOINT DANS XANO
  // Future<List<Restaurant>> searchRestaurantsByPlaceIDs(List<String> placeIDs) async {
  //   if (rootUrl.isEmpty) {
  //     throw Exception('Service not initialized. Call init() first.');
  //   }

  //   String endpoint = '$rootUrl/restaurantsByPlaceIDs';
  //   try {
  //     final response = await http.post(
  //       Uri.parse(endpoint),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({'placeIDs': placeIDs}),
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = json.decode(response.body);

  //       List<Restaurant> restaurants = jsonData.map((data) {
  //         return Restaurant.fromJson(data);
  //       }).toList();

  //       return restaurants;
  //     } else {
  //       throw Exception('Failed to search restaurants by place IDs');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to search restaurants by place IDs: $e');
  //   }
  // }

  Future<List<Workspace>> searchWorkspacesByAliass(List<String> alias) async {
    if (rootUrl.isEmpty) {
      throw Exception('Service not initialized. Call init() first.');
    }

    String endpoint = '$rootUrl/workspacesByAllias';
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'alliasList': alias}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Workspace> restaurants = jsonData.map((data) {
          return Workspace.fromJson(data);
        }).toList();

        return restaurants;
      } else {
        throw Exception('Failed to search restaurants by place IDs');
      }
    } catch (e) {
      throw Exception('Failed to search restaurants by place IDs: $e');
    }
  }
}
