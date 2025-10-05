import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';
import '../services/supabase_service.dart';
import '../services/ai_service.dart';
import 'package:uuid/uuid.dart';

class TodoProvider with ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  final List<TodoItem> _todoItems = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String? _error;

  List<TodoItem> get todoItems => _todoItems;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String? get error => _error;
  bool get isAuthenticated => _supabase.isAuthenticated;

  TodoProvider() {
    _initConnectivity();
    _loadLocalTodos();
  }

  // 네트워크 상태 확인
  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline && isAuthenticated) {
        // 오프라인에서 온라인으로 전환 시 동기화
        syncWithCloud();
      }
      
      notifyListeners();
    });

    final result = await connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  // 로컬 저장
  Future<void> _saveLocalTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _todoItems.map((item) => item.toJson()).toList();
      await prefs.setString('todos', jsonEncode(jsonList));
    } catch (e) {
      print('Error saving local todos: $e');
    }
  }

  // 로컬 불러오기
  Future<void> _loadLocalTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('todos');
      
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        _todoItems.clear();
        _todoItems.addAll(
          jsonList.map((json) => TodoItem.fromJson(json)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading local todos: $e');
    }
  }

  // 클라우드와 동기화
  Future<void> syncWithCloud() async {
    if (!isAuthenticated || !_isOnline) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cloudTodos = await _supabase.fetchTodos();
      _todoItems.clear();
      _todoItems.addAll(cloudTodos);
      await _saveLocalTodos();
    } catch (e) {
      _error = '동기화 실패: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 할 일 추가
  Future<void> addTodo(TodoItem item) async {
    _todoItems.insert(0, item);
    await _saveLocalTodos();
    notifyListeners();

    if (isAuthenticated && _isOnline) {
      try {
        await _supabase.addTodo(item);
      } catch (e) {
        _error = '클라우드 저장 실패 (로컬에는 저장됨)';
        notifyListeners();
      }
    }
  }

  // 할 일 업데이트
  Future<void> updateTodo(String id, TodoItem updatedItem) async {
    final index = _todoItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _todoItems[index] = updatedItem;
      await _saveLocalTodos();
      notifyListeners();

      if (isAuthenticated && _isOnline) {
        try {
          await _supabase.updateTodo(updatedItem);
        } catch (e) {
          _error = '클라우드 업데이트 실패 (로컬에는 저장됨)';
          notifyListeners();
        }
      }
    }
  }

  // 할 일 토글
  Future<void> toggleTodo(String id) async {
    final index = _todoItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _todoItems[index];
      item.isCompleted = !item.isCompleted;
      
      // 반복 일정인 경우 완료 시 다음 일정 생성
      if (item.isCompleted && 
          item.repeatType != RepeatType.none && 
          item.dueDate != null) {
        final nextDate = AIService.calculateNextDueDate(
          item.dueDate!,
          item.repeatType,
        );
        
        if (nextDate != null) {
          final newItem = item.copyWith(
            id: const Uuid().v4(),
            isCompleted: false,
            dueDate: nextDate,
            createdAt: DateTime.now(),
          );
          await addTodo(newItem);
        }
      }
      
      await _saveLocalTodos();
      notifyListeners();

      if (isAuthenticated && _isOnline) {
        try {
          await _supabase.updateTodo(_todoItems[index]);
        } catch (e) {
          _error = '클라우드 업데이트 실패';
          notifyListeners();
        }
      }
    }
  }

  // 할 일 삭제
  Future<void> deleteTodo(String id) async {
    final removedItem = _todoItems.firstWhere((item) => item.id == id);
    _todoItems.removeWhere((item) => item.id == id);
    await _saveLocalTodos();
    notifyListeners();

    if (isAuthenticated && _isOnline) {
      try {
        await _supabase.deleteTodo(id);
      } catch (e) {
        // 실패 시 복원
        _todoItems.add(removedItem);
        await _saveLocalTodos();
        _error = '삭제 실패';
        notifyListeners();
      }
    }
  }

  // 모두 삭제
  Future<void> deleteAll() async {
    _todoItems.clear();
    await _saveLocalTodos();
    notifyListeners();

    if (isAuthenticated && _isOnline) {
      await _supabase.deleteAllTodos();
    }
  }

  // JSON 백업
  String exportToJson() {
    final jsonList = _todoItems.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  // JSON 복원
  Future<void> importFromJson(String jsonString) async {
    try {
      final jsonList = jsonDecode(jsonString) as List;
      final importedItems = jsonList.map((json) => TodoItem.fromJson(json)).toList();
      
      _todoItems.clear();
      _todoItems.addAll(importedItems);
      await _saveLocalTodos();
      notifyListeners();

      // 클라우드에도 동기화
      if (isAuthenticated && _isOnline) {
        await _supabase.deleteAllTodos();
        for (var item in importedItems) {
          await _supabase.addTodo(item);
        }
      }
    } catch (e) {
      _error = '가져오기 실패: $e';
      notifyListeners();
    }
  }

  // 순서 변경
  void reorderTodos(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _todoItems.removeAt(oldIndex);
    _todoItems.insert(newIndex, item);
    _saveLocalTodos();
    notifyListeners();
  }
}
