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

  static TodoCategory fromString(String value) {
    return TodoCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TodoCategory.other,
    );
  }
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

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'category': category.name,
      'notes': notes,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      category: TodoCategory.fromString(json['category'] as String? ?? 'other'),
      notes: json['notes'] as String?,
    );
  }

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
    TodoCategory? category,
    String? notes,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}