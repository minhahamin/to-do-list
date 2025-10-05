import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../widgets/statistics_chart.dart';

class StatsDialog extends StatelessWidget {
  final List<TodoItem> todoItems;

  const StatsDialog({super.key, required this.todoItems});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    // 통계 계산
    final totalTasks = todoItems.length;
    final completedTasks = todoItems.where((item) => item.isCompleted).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

    final todayTasks = todoItems.where((item) => item.isDueToday).length;
    final overdueTasks = todoItems.where((item) => item.isOverdue).length;

    final weekTasks = todoItems.where((item) {
      return item.createdAt.isAfter(weekAgo);
    }).length;

    final weekCompletedTasks = todoItems.where((item) {
      return item.isCompleted && item.createdAt.isAfter(weekAgo);
    }).length;

    // 카테고리별 통계
    final categoryStats = <TodoCategory, int>{};
    for (var category in TodoCategory.values) {
      categoryStats[category] =
          todoItems.where((item) => item.category == category).length;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? Colors.grey[850] : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '통계 및 진행률',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 전체 통계
            _buildStatRow('총 할 일', '$totalTasks개', Icons.list, Colors.blue),
            _buildStatRow(
              '완료율',
              '${completionRate.toStringAsFixed(1)}%',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatRow('오늘 마감', '$todayTasks개', Icons.today, Colors.orange),
            _buildStatRow('지연됨', '$overdueTasks개', Icons.warning, Colors.red),
            const Divider(height: 32),
            // 주간 통계
            Text(
              '이번 주 (최근 7일)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow('생성된 할 일', '$weekTasks개', Icons.add, Colors.purple),
            _buildStatRow(
              '완료한 할 일',
              '$weekCompletedTasks개',
              Icons.done,
              Colors.teal,
            ),
            const Divider(height: 32),
            // 주간 그래프
            StatisticsChart(todoItems: todoItems),
            const Divider(height: 32),
            // 카테고리별 통계
            Text(
              '카테고리별 분포',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView(
                children: TodoCategory.values
                    .where((category) => categoryStats[category]! > 0)
                    .map((category) => _buildCategoryStatRow(
                          category,
                          categoryStats[category]!,
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatRow(TodoCategory category, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(category.icon, color: category.color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count개',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: category.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
