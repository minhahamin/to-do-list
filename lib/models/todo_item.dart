import 'package:flutter/material.dart';

enum TodoCategory {
  study('공부', Icons.school, Colors.blue),
  exercise('운동', Icons.fitness_center, Colors.green),
  project('프로젝트', Icons.computer, Colors.orange),
  personal('개인', Icons.person, Colors.purple),
  work('업무', Icons.work, Colors.red),
  other('기타', Icons.more_horiz, Colors.grey);

  const TodoCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum SortType {
  date('날짜순'),
  dueDate('마감일순'),
  category('카테고리순'),
  completed('완료순');

  const SortType(this.label);
  final String label;
}

class TodoItem {
  String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  DateTime createdAt;
  TodoCategory category;
  String? notes;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
    this.category = TodoCategory.other,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        category.label.toLowerCase().contains(lowerQuery);
  }
}
