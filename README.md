# BioLens

Application mobile Flutter pour identifier des plantes et construire un herbier numérique géolocalisé.

## Fonctionnalités

- Identification de plantes par photo via l'API PlantNet
- Choix de l'organe photographié (feuille, fleur, fruit, écorce) pour plus de précision
- Géolocalisation automatique ou sélection manuelle sur carte
- Herbier personnel avec fiches détaillées (nom, famille, date, localisation)
- Carte interactive des découvertes
- Statistiques et niveau de progression
- Thème clair/sombre

## Installation

1. Cloner le repo et installer les dépendances :
```bash
git clone https://github.com/SkayKer/biolens.git
cd biolens
flutter pub get
dart run build_runner build
```

2. Configurer la clé API PlantNet dans `lib/core/services/plant_api_service.dart` :
```dart
static const String _apiKey = 'YOUR_PLANTNET_API_KEY';
```
Clé disponible sur [my.plantnet.org](https://my.plantnet.org)

3. Lancer l'app :
```bash
flutter run
```

## Stack technique

- Flutter / Dart
- go_router (navigation)
- Isar (base de données locale)
- flutter_map + OpenStreetMap (cartes)
- API PlantNet (identification)
- API adresse.data.gouv.fr (géocodage)

## Auteurs

- Evan Bodineau - [GitHub](https://github.com/SkayKer)
- Antonin Urbain - [GitHub](https://github.com/Anto85)