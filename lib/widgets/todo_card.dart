import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
                          : item.priority == Priority.high
                              ? Colors.red.shade200
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          // 제목
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
                          // 메모
                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                            Text(
                              item.notes!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                          ],
                          // 배지들
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              // 카테고리
                              _buildBadge(
                                item.category.icon,
                                item.category.label,
                                item.category.color,
                              ),
                              // 우선순위
                              if (item.priority != Priority.medium)
                                _buildBadge(
                                  Icons.flag,
                                  item.priority.label,
                                  item.priority.color,
                                ),
                              // 마감일
                              if (item.dueDate != null)
                                _buildBadge(
                                  Icons.calendar_today,
                                  '${item.dueDate!.month}/${item.dueDate!.day}',
                                  item.isOverdue
                                      ? Colors.red
                                      : item.isDueToday
                                          ? Colors.orange
                                          : (isDark ? Colors.grey[400]! : Colors.grey),
                                ),
                              // 반복
                              if (item.repeatType != RepeatType.none)
                                _buildBadge(
                                  Icons.repeat,
                                  item.repeatType.label,
                                  Colors.blue,
                                ),
                              // 링크
                              if (item.links != null && item.links!.isNotEmpty)
                                InkWell(
                                  onTap: () => _launchUrl(item.links!.first),
                                  child: _buildBadge(
                                    Icons.link,
                                    '${item.links!.length}개',
                                    Colors.teal,
                                  ),
                                ),
                              // 서브태스크
                              if (item.subTasks != null && item.subTasks!.isNotEmpty)
                                _buildBadge(
                                  Icons.checklist,
                                  '${item.completedSubTasks}/${item.totalSubTasks}',
                                  item.completedSubTasks == item.totalSubTasks
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                            ],
                          ),
                          // 서브태스크 진행률
                          if (item.totalSubTasks > 0) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: item.subTaskProgress,
                                minHeight: 6,
                                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  item.category.color,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}