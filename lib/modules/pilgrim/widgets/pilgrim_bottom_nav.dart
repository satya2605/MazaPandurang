import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';

/// Custom 5-action bottom navigation bar for Pilgrim Module.
/// Features a prominent, visually elevated center Tilak AI action.
class PilgrimBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PilgrimBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Palkhi
          _NavNavItem(
            icon: Icons.flag_outlined,
            activeIcon: Icons.flag,
            label: 'Palkhi',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          // 2. Services
          _NavNavItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view,
            label: 'Services',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),

          // 3. Tilak AI (Elevated Floating Action)
          GestureDetector(
            onTap: () => onTap(3),
            child: Container(
              width: 56,
              height: 56,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(120),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                  Text(
                    'Tilak AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Bhakti
          _NavNavItem(
            icon: Icons.music_note_outlined,
            activeIcon: Icons.music_note,
            label: 'Bhakti',
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),

          // 5. Help
          _NavNavItem(
            icon: Icons.help_outline,
            activeIcon: Icons.help,
            label: 'Help',
            isSelected: currentIndex == 5,
            onTap: () => onTap(5),
          ),
        ],
      ),
    );
  }
}

class _NavNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
