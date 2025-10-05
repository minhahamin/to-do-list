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

enum RepeatType {
  none('반복 안 함'),
  daily('매일'),
  weekly('매주'),
  monthly('매달'),
  yearly('매년');

  const RepeatType(this.label);
  final String label;
}

enum Priority {
  low('낮음', Colors.green),
  medium('보통', Colors.orange),
  high('높음', Colors.red);

  const Priority(this.label, this.color);
  final String label;
  final Color color;
}

class SubTask {
  String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

class TodoItem {
  String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  DateTime createdAt;
  TodoCategory category;
  String? notes;
  List<String>? links;
  List<SubTask>? subTasks;
  RepeatType repeatType;
  Priority priority;
  String? projectId;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
    this.category = TodoCategory.other,
    this.notes,
    this.links,
    this.subTasks,
    this.repeatType = RepeatType.none,
    this.priority = Priority.medium,
    this.projectId,
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
        category.label.toLowerCase().contains(lowerQuery) ||
        (notes?.toLowerCase().contains(lowerQuery) ?? false);
  }

  int get completedSubTasks {
    if (subTasks == null) return 0;
    return subTasks!.where((task) => task.isCompleted).length;
  }

  int get totalSubTasks => subTasks?.length ?? 0;

  double get subTaskProgress {
    if (totalSubTasks == 0) return 0;
    return completedSubTasks / totalSubTasks;
  }

  // AI 자동 분류
  static TodoCategory suggestCategory(String title, String? notes) {
    final text = '${title.toLowerCase()} ${notes?.toLowerCase() ?? ''}';
    
    // 공부 키워드
    if (text.contains('공부') || text.contains('숙제') || 
        text.contains('과제') || text.contains('시험') ||
        text.contains('강의') || text.contains('학습')) {
      return TodoCategory.study;
    }
    
    // 운동 키워드
    if (text.contains('운동') || text.contains('헬스') || 
        text.contains('러닝') || text.contains('요가') ||
        text.contains('조깅') || text.contains('피트니스')) {
      return TodoCategory.exercise;
    }
    
    // 프로젝트 키워드
    if (text.contains('프로젝트') || text.contains('개발') || 
        text.contains('코딩') || text.contains('프로그래밍') ||
        text.contains('설계') || text.contains('개발')) {
      return TodoCategory.project;
    }
    
    // 업무 키워드
    if (text.contains('회의') || text.contains('미팅') || 
        text.contains('보고서') || text.contains('출근') ||
        text.contains('업무') || text.contains('회사')) {
      return TodoCategory.work;
    }
    
    return TodoCategory.other;
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
      'links': links,
      'sub_tasks': subTasks?.map((task) => task.toJson()).toList(),
      'repeat_type': repeatType.name,
      'priority': priority.name,
      'project_id': projectId,
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
      links: (json['links'] as List?)?.map((e) => e as String).toList(),
      subTasks: (json['sub_tasks'] as List?)
          ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == (json['repeat_type'] as String? ?? 'none'),
        orElse: () => RepeatType.none,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.name == (json['priority'] as String? ?? 'medium'),
        orElse: () => Priority.medium,
      ),
      projectId: json['project_id'] as String?,
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
    List<String>? links,
    List<SubTask>? subTasks,
    RepeatType? repeatType,
    Priority? priority,
    String? projectId,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      links: links ?? this.links,
      subTasks: subTasks ?? this.subTasks,
      repeatType: repeatType ?? this.repeatType,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
    );
  }
}