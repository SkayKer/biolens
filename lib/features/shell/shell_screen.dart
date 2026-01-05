import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Écran principal avec la barre de navigation personnalisée.
///
/// Utilise un BottomAppBar avec encoche pour le FAB central (Scan).
/// Les onglets Herbier et Profil sont de chaque côté.
/// Utilise les couleurs du thème pour s'adapter au mode sombre.
class ShellScreen extends StatefulWidget {
  /// Widget enfant affiché dans le corps du Scaffold
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  /// Retourne l'index de l'onglet actif basé sur la route courante
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/profile')) return 1;
    return 0; // herbier par défaut
  }

  /// Navigue vers la route correspondant à l'index
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/herbier');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,

      // ═══════════════════════════════════════════════════════════════════════
      // FLOATING ACTION BUTTON - Bouton Scan central proéminent
      // ═══════════════════════════════════════════════════════════════════════
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Couleur pleine sans dégradé
          color: colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/scan'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: SvgPicture.asset(
            'assets/icons/icon_scan.svg',
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(
              colorScheme.onPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ═══════════════════════════════════════════════════════════════════════
      // BOTTOM APP BAR - Barre avec encoche pour le FAB
      // ═══════════════════════════════════════════════════════════════════════
      bottomNavigationBar: BottomAppBar(
        height: 65,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        // Utiliser la couleur de surface du thème
        color: colorScheme.surface,
        elevation: 8,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : colorScheme.primary.withValues(alpha: 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ═════════════════════════════════════════════════════════════════
            // BOUTON HERBIER (Gauche)
            // ═════════════════════════════════════════════════════════════════
            Expanded(
              child: _NavBarItem(
                icon: 'assets/icons/icon_book.svg',
                label: 'Herbier',
                isSelected: currentIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
            ),

            // Espace pour le FAB central
            const SizedBox(width: 80),

            // ═════════════════════════════════════════════════════════════════
            // BOUTON PROFIL (Droite)
            // ═════════════════════════════════════════════════════════════════
            Expanded(
              child: _NavBarItem(
                icon: 'assets/icons/icon_profile.svg',
                label: 'Profil',
                isSelected: currentIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour un élément de la barre de navigation.
///
/// Utilise les couleurs du thème pour s'adapter au mode sombre.
class _NavBarItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Couleur sélectionnée = primary, non sélectionnée = onSurfaceVariant
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
