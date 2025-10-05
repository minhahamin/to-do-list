import '../models/todo_item.dart';

class AIService {
  // AI 기반 카테고리 자동 분류
  static TodoCategory suggestCategory(String title, String? notes) {
    return TodoItem.suggestCategory(title, notes);
  }

  // AI 기반 우선순위 제안
  static Priority suggestPriority(String title, DateTime? dueDate) {
    final text = title.toLowerCase();
    
    // 긴급 키워드
    if (text.contains('급한') || text.contains('긴급') || 
        text.contains('빨리') || text.contains('중요') ||
        text.contains('urgent') || text.contains('asap')) {
      return Priority.high;
    }
    
    // 마감일이 오늘이거나 내일이면 높은 우선순위
    if (dueDate != null) {
      final now = DateTime.now();
      final diff = dueDate.difference(now).inDays;
      if (diff <= 1) return Priority.high;
      if (diff <= 3) return Priority.medium;
    }
    
    return Priority.low;
  }

  // 반복 일정 다음 날짜 계산
  static DateTime? calculateNextDueDate(DateTime currentDate, RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.none:
        return null;
      case RepeatType.daily:
        return currentDate.add(const Duration(days: 1));
      case RepeatType.weekly:
        return currentDate.add(const Duration(days: 7));
      case RepeatType.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      case RepeatType.yearly:
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );
    }
  }
}
