import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class CategoryChip extends StatelessWidget {
  final TodoCategory? category;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? Colors.deepPurple;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : color,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) => onTap(),
        backgroundColor: isDark
            ? Colors.grey[800]?.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : isDark
                  ? Colors.white
                  : color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
