import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Écran de sélection manuelle de la localisation.
///
/// Permet de rechercher une adresse ou de pointer directement sur la carte.
class LocationPickerScreen extends StatefulWidget {
  /// Latitude initiale (optionnelle)
  final double? initialLatitude;

  /// Longitude initiale (optionnelle)
  final double? initialLongitude;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  /// Contrôleur de la carte
  final MapController _mapController = MapController();

  /// Contrôleur du champ de recherche
  final TextEditingController _searchController = TextEditingController();

  /// Service de localisation
  final LocationService _locationService = LocationService();

  /// Position sélectionnée
  LatLng? _selectedPosition;

  /// Résultats de recherche
  List<AddressResult> _searchResults = [];

  /// Indique si une recherche est en cours
  bool _isSearching = false;

  /// Timer pour le debounce de la recherche
  Timer? _debounceTimer;

  /// Centre initial de la carte (France)
  static const LatLng _franceCenter = LatLng(46.603354, 1.888334);

  @override
  void initState() {
    super.initState();
    // Si des coordonnées initiales sont fournies, les utiliser
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPosition = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Recherche une adresse avec debounce.
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchAddress(query);
    });
  }

  /// Effectue la recherche d'adresse.
  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _locationService.searchAddress(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  /// Sélectionne une adresse depuis les résultats.
  void _selectAddress(AddressResult address) {
    final position = LatLng(address.latitude, address.longitude);
    setState(() {
      _selectedPosition = position;
      _searchResults = [];
      _searchController.text = address.label;
    });

    // Centrer la carte sur l'adresse
    _mapController.move(position, 15);
  }

  /// Sélectionne une position en tapant sur la carte.
  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() => _selectedPosition = position);

    // Recherche inverse pour afficher l'adresse
    _reverseGeocode(position);
  }

  /// Effectue un reverse geocoding pour afficher l'adresse.
  Future<void> _reverseGeocode(LatLng position) async {
    final address = await _locationService.reverseGeocode(
      position.latitude,
      position.longitude,
    );

    if (address != null && mounted) {
      _searchController.text = address.label;
    }
  }

  /// Valide la sélection et retourne les coordonnées.
  void _confirmSelection() {
    if (_selectedPosition != null) {
      context.pop({
        'latitude': _selectedPosition!.latitude,
        'longitude': _selectedPosition!.longitude,
      });
    }
  }

  /// Annule et retourne sans localisation.
  void _skipLocation() {
    context.pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(
          'Localisation',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: _skipLocation,
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _skipLocation,
            child: Text(
              'Passer',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // BARRE DE RECHERCHE
          // ═══════════════════════════════════════════════════════════════════
          _buildSearchBar(),

          // ═══════════════════════════════════════════════════════════════════
          // CARTE
          // ═══════════════════════════════════════════════════════════════════
          Expanded(
            child: Stack(
              children: [
                _buildMap(),

                // Résultats de recherche superposés
                if (_searchResults.isNotEmpty) _buildSearchResults(),
              ],
            ),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // BOUTON DE VALIDATION
          // ═══════════════════════════════════════════════════════════════════
          _buildConfirmButton(),
        ],
      ),
    );
  }

  /// Construit la barre de recherche.
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher une adresse...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Construit la carte.
  Widget _buildMap() {
    // Utiliser la position sélectionnée comme centre si disponible
    final center = _selectedPosition ?? _franceCenter;
    final zoom = _selectedPosition != null ? 15.0 : 6.0;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onTap: _onMapTap,
      ),
      children: [
        // Couche de tuiles OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.biolens.app',
        ),

        // Marqueur de la position sélectionnée
        if (_selectedPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPosition!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_pin,
                  color: AppColors.error,
                  size: 50,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Construit la liste des résultats de recherche.
  Widget _buildSearchResults() {
    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final address = _searchResults[index];
              return ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
                title: Text(
                  address.label,
                  style: AppTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: address.city != null
                    ? Text(
                        '${address.postcode ?? ''} ${address.city}',
                        style: AppTypography.bodySmall,
                      )
                    : null,
                onTap: () => _selectAddress(address),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Construit le bouton de validation.
  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedPosition != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Position: ${_selectedPosition!.latitude.toStringAsFixed(4)}, ${_selectedPosition!.longitude.toStringAsFixed(4)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPosition != null ? _confirmSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.border,
                ),
                child: Text(
                  'Confirmer la localisation',
                  style: AppTypography.labelLarge.copyWith(
                    color: _selectedPosition != null
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
