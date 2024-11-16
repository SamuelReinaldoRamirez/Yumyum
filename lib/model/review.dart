import 'package:logger/logger.dart';
import 'package:yummap/model/review_interface.dart';

class Review implements ReviewInterface {
  final int id;
  final String _comment; // Champ privé pour le commentaire
  final double _rating; // Champ privé pour la note
  final int user_id;
  final int restaurants_id;
  final int workspace_id;
  final String _workspaceName; // Champ privé pour le nom du workspace

  Review({
    required this.id,
    required String comment, // Utilisation du paramètre `comment`
    required double rating, // Utilisation du paramètre `rating`
    required this.user_id,
    required this.restaurants_id,
    required this.workspace_id,
    required String
        workspaceName, // Ajout du paramètre pour le nom du workspace
  })  : _comment = comment, // Initialisation du champ privé
        _rating = rating, // Initialisation du champ privé
        _workspaceName = workspaceName; // Initialisation du champ privé

  @override
  String get comment => _comment;

  @override
  double get rating => _rating;

  @override
  String get author => _workspaceName;

  @override
  String get type => "des Hôtels";

  // Méthode pour créer une instance de Review à partir d'un JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    final logger = Logger();
    logger.e(json);

    // On vérifie que `rating` est bien un double, même si la valeur est un entier
    double parsedRating;
    if (json['rating'] is int) {
      parsedRating = (json['rating'] as int).toDouble();
    } else if (json['rating'] is double) {
      parsedRating = json['rating'];
    } else {
      // Si `rating` n'est ni un entier ni un double, on le met à 0.0 par défaut
      parsedRating = 0.0;
    }

    return Review(
      id: json['id'] ?? 0,
      comment: json['comment'] ?? '',
      rating: parsedRating, // Assurez-vous que `rating` est bien un double
      user_id: json['user_id'] ?? 0,
      restaurants_id: json['restaurants_id'] ?? 0,
      workspace_id: json['workspace_id'] ?? 0,
      workspaceName: json['_workspace']?['name'] ??
          'Workspace #${json['workspace_id']}', // Récupération du nom du workspace depuis l'objet `_workspace`
    );
  }
}
