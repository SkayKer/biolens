import 'package:flutter/material.dart';

/// CustomPainter pour dessiner le viseur de l'écran de scan.
/// 
/// Dessine 4 coins en L avec un overlay semi-transparent.
class ViewfinderPainter extends CustomPainter {
  /// Couleur du cadre
  final Color frameColor;
  
  /// Épaisseur du trait
  final double frameWidth;
  
  /// Longueur des coins
  final double cornerLength;
  
  /// Opacité de l'overlay extérieur
  final double overlayOpacity;
  
  /// Ratio du viseur (largeur/hauteur)
  final double viewfinderRatio;

  ViewfinderPainter({
    this.frameColor = Colors.white,
    this.frameWidth = 3.0,
    this.cornerLength = 30.0,
    this.overlayOpacity = 0.5,
    this.viewfinderRatio = 1.0, // Carré par défaut
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculer la taille et position du viseur (70% de la largeur)
    final viewfinderWidth = size.width * 0.7;
    final viewfinderHeight = viewfinderWidth / viewfinderRatio;
    
    final left = (size.width - viewfinderWidth) / 2;
    final top = (size.height - viewfinderHeight) / 2;
    final right = left + viewfinderWidth;
    final bottom = top + viewfinderHeight;

    final viewfinderRect = Rect.fromLTRB(left, top, right, bottom);

    // ═══════════════════════════════════════════════════════════════════════
    // DESSINER L'OVERLAY SEMI-TRANSPARENT
    // ═══════════════════════════════════════════════════════════════════════
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: overlayOpacity)
      ..style = PaintingStyle.fill;

    // Dessiner l'overlay avec un trou pour le viseur
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(viewfinderRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(overlayPath, overlayPaint);

    // ═══════════════════════════════════════════════════════════════════════
    // DESSINER LES COINS DU VISEUR
    // ═══════════════════════════════════════════════════════════════════════
    final cornerPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = frameWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Coin supérieur gauche
    _drawCorner(canvas, cornerPaint, left, top, cornerLength, 1, 1);
    
    // Coin supérieur droit
    _drawCorner(canvas, cornerPaint, right, top, cornerLength, -1, 1);
    
    // Coin inférieur gauche
    _drawCorner(canvas, cornerPaint, left, bottom, cornerLength, 1, -1);
    
    // Coin inférieur droit
    _drawCorner(canvas, cornerPaint, right, bottom, cornerLength, -1, -1);
  }

  /// Dessine un coin en L.
  /// 
  /// [dirX] et [dirY] déterminent l'orientation du coin (-1 ou 1).
  void _drawCorner(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double length,
    int dirX,
    int dirY,
  ) {
    final path = Path();
    
    // Ligne horizontale
    path.moveTo(x, y);
    path.lineTo(x + length * dirX, y);
    
    // Ligne verticale
    path.moveTo(x, y);
    path.lineTo(x, y + length * dirY);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ViewfinderPainter oldDelegate) {
    return oldDelegate.frameColor != frameColor ||
        oldDelegate.frameWidth != frameWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.overlayOpacity != overlayOpacity ||
        oldDelegate.viewfinderRatio != viewfinderRatio;
  }
}
