import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'widgets/viewfinder_painter.dart';

/// Écran de scan avec caméra plein écran et viseur.
/// 
/// Permet de photographier une plante pour l'identifier.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  /// Contrôleur de la caméra
  CameraController? _controller;
  
  /// Liste des caméras disponibles
  List<CameraDescription> _cameras = [];
  
  /// Indique si la caméra est initialisée
  bool _isInitialized = false;
  
  /// Indique si une capture est en cours
  bool _isCapturing = false;
  
  /// Message d'erreur éventuel
  String? _errorMessage;

  /// Image picker pour la galerie
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Initialise la caméra arrière.
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        setState(() => _errorMessage = 'Aucune caméra disponible');
        return;
      }

      // Sélectionner la caméra arrière
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur caméra: $e');
    }
  }

  /// Capture une photo.
  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      _navigateToIdentification(File(photo.path));
    } catch (e) {
      _showError('Erreur lors de la capture: $e');
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  /// Ouvre la galerie pour sélectionner une image.
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        _navigateToIdentification(File(image.path));
      }
    } catch (e) {
      _showError('Erreur lors de la sélection: $e');
    }
  }

  /// Navigue vers l'écran d'identification avec l'image.
  void _navigateToIdentification(File imageFile) {
    context.pushNamed('scanResult', extra: imageFile.path);
  }

  /// Affiche une erreur.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // COUCHE 1: Camera Preview (Fond)
          // ═══════════════════════════════════════════════════════════════════
          _buildCameraPreview(),

          // ═══════════════════════════════════════════════════════════════════
          // COUCHE 2: Viewfinder Overlay (Milieu)
          // ═══════════════════════════════════════════════════════════════════
          CustomPaint(
            painter: ViewfinderPainter(
              frameColor: Colors.white,
              frameWidth: 3.0,
              cornerLength: 30.0,
              overlayOpacity: 0.5,
            ),
            size: Size.infinite,
          ),

          // ═══════════════════════════════════════════════════════════════════
          // COUCHE 3: UI Controls (Haut)
          // ═══════════════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la preview de la caméra.
  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Calculer le ratio pour remplir l'écran
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final cameraRatio = _controller!.value.aspectRatio;

    return Center(
      child: Transform.scale(
        scale: cameraRatio / deviceRatio,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  /// Construit la barre supérieure.
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Bouton retour
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          const Spacer(),
          // Titre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Scanner une plante',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Équilibre avec le bouton retour
        ],
      ),
    );
  }

  /// Construit les contrôles inférieurs.
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instructions
          Text(
            'Cadrez la plante dans le viseur',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          
          // Boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton Galerie
              _buildGalleryButton(),
              
              // Bouton Scanner (principal)
              _buildScannerButton(),
              
              // Espace vide pour équilibrer
              const SizedBox(width: 56),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Construit le bouton principal "Scanner" en forme de pilule.
  Widget _buildScannerButton() {
    return GestureDetector(
      onTap: _isCapturing ? null : _capturePhoto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isCapturing
                ? [AppColors.textSecondary, AppColors.textSecondary]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isCapturing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 24,
              ),
            const SizedBox(width: 12),
            Text(
              _isCapturing ? 'Capture...' : 'Scanner',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le bouton de galerie.
  Widget _buildGalleryButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _pickFromGallery,
        icon: const Icon(Icons.photo_library_outlined),
        color: Colors.white,
        iconSize: 28,
        padding: const EdgeInsets.all(14),
      ),
    );
  }
}
