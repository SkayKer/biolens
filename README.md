# 🌿 BioLens

**BioLens** est une application mobile Flutter de reconnaissance et d'identification de plantes. Photographiez une plante, identifiez-la grâce à l'intelligence artificielle, et construisez votre herbier numérique géolocalisé.

## ✨ Fonctionnalités

### 📸 Scan & Identification
- **Capture photo** : Prenez une photo ou sélectionnez-en une depuis votre galerie
- **Identification IA** : Reconnaissance automatique via l'API PlantNet
- **Sélection d'organe** : Spécifiez si vous photographiez une feuille, fleur, fruit ou écorce pour améliorer la précision
- **Résultats détaillés** : Consultez plusieurs propositions avec leur score de confiance

### 🗺️ Géolocalisation
- **Localisation automatique** : GPS automatique lors de la prise de photo
- **Sélection manuelle** : Pointez manuellement votre position sur une carte de France
- **Recherche d'adresse** : Trouvez votre localisation en tapant une adresse (API adresse.gouv.fr)
- **Carte interactive** : Visualisez toutes vos plantes découvertes sur une carte avec marqueurs photo

### 📚 Herbier Personnel
- **Collection numérique** : Conservez toutes vos découvertes botaniques
- **Fiches détaillées** : Nom scientifique, nom commun, famille, description, date et localisation
- **Grille visuelle** : Navigation intuitive en grille de 2 colonnes
- **Suppression sécurisée** : Supprimez des plantes avec confirmation

### 👤 Profil & Statistiques
- **Niveau d'expertise** : Progression de "Débutant" à "Botaniste Expert"
- **Statistiques** : Nombre de plantes découvertes, dernière découverte
- **Aperçu carte** : Mini-carte des découvertes avec accès rapide à la vue complète
- **Partage** : Partagez vos découvertes

## 🛠️ Technologies

### Framework & Langage
- **Flutter** `^3.10.1` - Framework UI multiplateforme
- **Dart** - Langage de programmation

### Architecture
- **go_router** `^14.6.2` - Navigation déclarative avec routes nommées
- **Isar** `^3.1.0` - Base de données locale NoSQL haute performance

### APIs & Services
- **PlantNet API** - Identification de plantes par IA
- **API Adresse Data Gouv** - Géocodage et recherche d'adresses françaises
- **OpenStreetMap** - Tuiles cartographiques

### Packages Principaux
- `camera` `^0.11.0` - Accès à la caméra
- `image_picker` `^1.1.2` - Sélection d'images depuis la galerie
- `geolocator` `^14.0.2` - Services de géolocalisation GPS
- `flutter_map` `^7.0.2` - Affichage de cartes interactives
- `latlong2` `^0.9.1` - Manipulation de coordonnées GPS
- `http` `^1.2.2` - Requêtes HTTP
- `path_provider` `^2.1.5` - Accès aux répertoires système
- `google_fonts` `^6.2.1` - Typographie personnalisée
- `share_plus` `^10.1.4` - Partage de contenu

## 📁 Structure du Projet

```
lib/
├── main.dart                          # Point d'entrée de l'application
├── core/
│   ├── models/                        # Modèles de données
│   │   ├── saved_plant.dart          # Modèle Isar de plante sauvegardée
│   │   └── plant_identification.dart # Résultat d'identification API
│   ├── services/                      # Services métier
│   │   ├── local_storage_service.dart # Gestion base de données Isar
│   │   ├── plant_api_service.dart     # Client API PlantNet
│   │   └── location_service.dart      # Services GPS et géocodage
│   ├── router/
│   │   └── app_router.dart            # Configuration go_router
│   └── theme/                         # Design system
│       ├── app_colors.dart            # Palette de couleurs
│       ├── app_typography.dart        # Styles de texte
│       └── app_theme.dart             # Thème global
└── features/                          # Fonctionnalités par écran
    ├── shell/
    │   └── shell_screen.dart          # Navigation principale (bottom nav)
    ├── scan/
    │   ├── scan_screen.dart           # Écran de capture photo
    │   ├── scan_result_screen.dart    # Résultat & identification
    │   └── location_picker_screen.dart # Sélection manuelle localisation
    ├── herbier/
    │   ├── herbier_screen.dart        # Grille des plantes
    │   └── widgets/
    │       └── plant_tile.dart        # Tuile de plante
    ├── species/
    │   └── species_detail_screen.dart # Détails d'une plante
    └── profile/
        ├── profile_screen.dart        # Profil & stats
        ├── plants_map_screen.dart     # Carte plein écran
        └── widgets/
            └── stat_card.dart         # Carte de statistique

```

## 🚀 Installation

### Prérequis
- Flutter SDK `>=3.10.1`
- Dart SDK `>=3.10.1`
- Xcode (pour iOS) ou Android Studio (pour Android)
- Compte PlantNet pour obtenir une clé API

### Étapes

1. **Cloner le repository**
```bash
git clone https://github.com/SkayKer/biolens.git
cd biolens
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les fichiers Isar**
```bash
dart run build_runner build
```

4. **Configurer la clé API PlantNet**

Éditez `lib/core/services/plant_api_service.dart` et remplacez :
```dart
static const String _apiKey = 'YOUR_PLANTNET_API_KEY';
```

Obtenez votre clé sur : [my.plantnet.org](https://my.plantnet.org)

5. **Configurer les permissions iOS**

Ajoutez dans `ios/Runner/Info.plist` :
```xml
<key>NSCameraUsageDescription</key>
<string>BioLens a besoin d'accéder à la caméra pour photographier les plantes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>BioLens a besoin d'accéder à vos photos pour sélectionner des images de plantes</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>BioLens utilise votre position pour géolocaliser vos découvertes</string>
```

6. **Lancer l'application**
```bash
flutter run
```

## 🎨 Design System

### Couleurs
- **Primary** : `#2E7D32` (vert nature)
- **Secondary** : `#81C784` (vert clair)
- **Background** : `#F5F5F5`
- **Surface** : `#FFFFFF`
- **Error** : `#D32F2F`

### Typographie
Utilise **Google Fonts Poppins** pour une apparence moderne et lisible.

## 📱 Navigation

L'application utilise `go_router` avec les routes suivantes :

| Route | Écran | Description |
|-------|-------|-------------|
| `/herbier` | HerbierScreen | Page d'accueil - grille des plantes |
| `/scan` | ScanScreen | Capture photo (plein écran) |
| `/scan/result` | ScanResultScreen | Résultat après capture |
| `/location-picker` | LocationPickerScreen | Sélection manuelle localisation |
| `/profile` | ProfileScreen | Profil et statistiques |
| `/plants-map` | PlantsMapScreen | Carte plein écran |
| `/species/:id` | SpeciesDetailScreen | Détails d'une plante |

## 🗄️ Modèle de Données

### SavedPlant (Isar Collection)
```dart
class SavedPlant {
  Id id;                         // Auto-incrémenté
  String scientificName;         // Nom latin
  String commonName;             // Nom commun
  String? family;                // Famille botanique
  String imagePath;              // Chemin image locale
  String? imageUrl;              // URL image API
  String? description;           // Description
  double? identificationScore;   // Score (0.0-1.0)
  DateTime discoveryDate;        // Date de scan
  double? latitude;              // Coordonnée GPS
  double? longitude;             // Coordonnée GPS
  bool isFavorite;               // Favoris
}
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.

## 👨‍💻 Auteur

**SkayKer** - [GitHub](https://github.com/SkayKer)

## 🙏 Remerciements

- [PlantNet](https://plantnet.org/) pour l'API d'identification
- [API Adresse Data Gouv](https://adresse.data.gouv.fr/) pour le géocodage
- [OpenStreetMap](https://www.openstreetmap.org/) pour les cartes
- La communauté Flutter pour les packages excellents

---

*Développé avec 💚 et Flutter*