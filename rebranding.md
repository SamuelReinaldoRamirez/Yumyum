# Rebranding de l'application Yummap

## Nouvelle palette

### Palette finale pour Yummap :

1. **Couleur de fond** :
    - **Blanc cassé** (#F1E8D2)
2. **Couleur principale** (pour boutons, icônes, titres) :
    - **Bleu pastel** (#A3C8D9)
3. **Couleur secondaire** (pour accents, éléments interactifs) :
    - **Bleu foncé** (#3A7BB7)
4. **Couleur du texte** :
    - **Gris très clair** (#4A4A4A) pour une bonne lisibilité.

### Utilisation cohérente :

- **Fond général** : Blanc cassé (#F1E8D2) pour une interface légère et aérée.
- **Titres** : Bleu pastel (#A3C8D9) pour un contraste subtil et une hiérarchie claire.
- **Texte** : Gris très clair (#4A4A4A) pour le corps du texte.
- **Éléments interactifs** : Le bleu foncé (#3A7BB7) sera utilisé pour les boutons, liens et éléments interactifs.

## Plan de Rebranding Yummap

## 1. Configuration Initiale (Jour 1)

### 1.1 Mise à jour du pubspec.yaml
- [ ] Mettre à jour les dépendances
- [ ] Ajouter les polices Playfair Display et Source Sans Pro

### 1.2 Création des constantes (constant/theme.dart)
- [ ] Définir la palette de couleurs
- [ ] Configurer les styles typographiques
- [ ] Créer les styles de base pour les composants

## 2. Mise à jour du Design System (Jour 2-3)

### 2.1 Composants de Base
- [ ] Mettre à jour les boutons
- [ ] Mettre à jour les champs de texte
- [ ] Mettre à jour les cartes
- [ ] Mettre à jour les bottom sheets
- [ ] Mettre à jour les barres de navigation

### 2.2 Typographie
- [ ] Définir les styles de titres (Playfair Display)
  - [ ] H1: 32px
  - [ ] H2: 24px
  - [ ] H3: 20px
- [ ] Définir les styles de corps du texte (Source Sans Pro)
  - [ ] Corps: 16px
  - [ ] Petit texte: 14px

## 3. Implementation du Style Neubrutalism (Jour 4-5)

### 3.1 Caractéristiques Visuelles
- [ ] Appliquer des bordures épaisses (3px)
- [ ] Ajouter des ombres décalées
- [ ] Arrondir légèrement les coins
- [ ] Ajouter des animations au clic

### 3.2 Palette de Couleurs
- [ ] Appliquer le fond: #F1E8D2 (Blanc cassé)
- [ ] Appliquer la couleur principale: #A3C8D9 (Bleu pastel)
- [ ] Appliquer la couleur secondaire: #3A7BB7 (Bleu foncé)
- [ ] Appliquer la couleur du texte: #4A4A4A (Gris très clair)

## 4. Mise à Jour des Écrans (Jour 6-8)

### 4.1 Pages Principales
- [ ] Mettre à jour la page d'accueil
- [ ] Mettre à jour la liste des restaurants
- [ ] Mettre à jour les détails du restaurant
- [ ] Mettre à jour le profil utilisateur

### 4.2 Composants Spécifiques
- [ ] Mettre à jour les cartes de restaurants
- [ ] Mettre à jour les filtres de recherche
- [ ] Mettre à jour le menu de navigation
- [ ] Mettre à jour les modales et popups

## 5. Tests et Ajustements (Jour 9-10)

### 5.1 Tests
- [ ] Effectuer des tests de cohérence visuelle
- [ ] Effectuer des tests de responsive design
- [ ] Effectuer des tests d'accessibilité
- [ ] Effectuer des tests de performance

### 5.2 Optimisations
- [ ] Ajuster les contrastes
- [ ] Optimiser les animations
- [ ] Corriger les espacements

## 6. Documentation (Jour 10)

### 6.1 Guide de Style
- [ ] Rédiger les règles d'utilisation des composants
- [ ] Rédiger les guidelines typographiques
- [ ] Rédiger l'utilisation des couleurs
- [ ] Rédiger les espacements et grille

### 6.2 Documentation Technique
- [ ] Documenter la structure des fichiers
- [ ] Documenter l'utilisation des composants
- [ ] Documenter les conventions de nommage
- [ ] Documenter les bonnes pratiques

## Ressources et Dépendances

### Polices
- Playfair Display (Titres)
- Source Sans Pro (Corps du texte)

### Outils Recommandés
- Flutter DevTools pour le debugging
- Material Theme Editor
- Flutter Inspector

## Notes Importantes
- Maintenir la cohérence visuelle
- Respecter les principes du Neubrutalism
- Assurer l'accessibilité
- Optimiser les performances

## Modifications à apporter dans le code

### 1. Mise à jour du fichier `theme.dart`

```dart
class AppColors {
  // Couleurs de base
  static const Color backgroundColor = Color(0xFFF1E8D2);
  static const Color primaryColor = Color(0xFFA3C8D9);
  static const Color secondaryColor = Color(0xFF3A7BB7);
  static const Color textColor = Color(0xFF4A4A4A);
  
  // Couleurs pour les ombres
  static const Color shadowColor = Colors.black;
  
  // Couleurs pour les bordures
  static const Color borderColor = Colors.black;
}

class AppTheme {
  static final ThemeData neoBrutalTheme = ThemeData(
    // Styles généraux
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        elevation: MaterialStateProperty.all(8),
        padding: MaterialStateProperty.all(EdgeInsets.all(16)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.black, width: 3),
          ),
        ),
      ),
    ),
    
    // Styles des cartes
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.black, width: 3),
      ),
    ),
  );
}
```

### 2. Modifications dans `bottom_sheet_helper.dart`

```dart
class BottomSheetHelper {
  static Widget buildBottomSheet({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
```

### 3. Modifications à apporter aux widgets principaux

1. **Boutons** :
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.black,
    elevation: 8,
    padding: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: BorderSide(color: Colors.black, width: 3),
    ),
  ),
  child: Text('Button'),
  onPressed: () {},
)
```

2. **Cartes de restaurants** :
```dart
Card(
  margin: EdgeInsets.all(16),
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      border: Border.all(color: Colors.black, width: 3),
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          offset: Offset(4, 4),
          blurRadius: 0,
        ),
      ],
    ),
    child: YourContent(),
  ),
)
```

3. **Champs de texte** :
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: Colors.black, width: 3),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: Colors.black, width: 3),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: Colors.black, width: 3),
    ),
  ),
)
```

### 4. Principes généraux à appliquer

1. **Bordures** :
   - Utilisez des bordures noires épaisses (3px)
   - Coins légèrement arrondis (4px)

2. **Ombres** :
   - Ombres décalées (offset de 4px)
   - Pas de flou (blurRadius: 0)
   - Couleur noire pure

3. **Espacement** :
   - Utilisez des marges et paddings généreux
   - Maintenez une grille cohérente (multiples de 8)

4. **Typographie** :
   - Utilisez des polices sans serif audacieuses
   - Tailles de texte plus grandes que la normale

### 5. Animations

Ajoutez des animations simples pour les interactions :

```dart
// Pour les boutons
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  transform: Matrix4.translation(
    isPressed ? Vector3(2, 2, 0) : Vector3(0, 0, 0),
  ),
  child: YourButton(),
)
```

Ces modifications créeront une interface distinctive avec un style Neubrutalism marqué.
