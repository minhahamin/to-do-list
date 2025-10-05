import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoCard extends StatelessWidget {
  final TodoItem item;
  final bool isDark;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? (isDark ? Colors.grey[850] : Colors.grey.shade50)
                    : (isDark ? Colors.grey[800] : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: item.isOverdue
                      ? Colors.red.shade300
                      : item.isDueToday
                          ? Colors.orange.shade300
                          : item.isCompleted
                              ? (isDark ? Colors.grey[700]! : Colors.grey.shade200)
                              : item.category.color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Drag handle (index가 -1이면 숨김)
                    if (index >= 0)
                      ReorderableDragStartListener(
                        index: index,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.grey[800] 
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.drag_indicator,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 8),
                    // 체크박스
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: item.isCompleted,
                        onChanged: (bool? value) => onToggle(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        activeColor: item.category.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 내용
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item.isCompleted
                                  ? (isDark ? Colors.grey[600] : Colors.grey[400])
                                  : (isDark ? Colors.grey[200] : Colors.grey[800]),
                              fontWeight: item.isCompleted
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // 카테고리 뱃지
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item.category.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.category.icon,
                                      size: 12,
                                      color: item.category.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.category.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: item.category.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.dueDate != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: item.isOverdue
                                      ? Colors.red
                                      : item.isDueToday
                                          ? Colors.orange
                                          : (isDark ? Colors.grey[400] : Colors.grey),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.dueDate!.month}/${item.dueDate!.day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.isOverdue
                                        ? Colors.red
                                        : item.isDueToday
                                            ? Colors.orange
                                            : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                    fontWeight: item.isOverdue || item.isDueToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
