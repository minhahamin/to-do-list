import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo_item.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // 인증 상태
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // 이메일 로그인
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 이메일 회원가입
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // 구글 로그인
  Future<bool> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      return true;
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // 할 일 가져오기
  Future<List<TodoItem>> fetchTodos() async {
    if (!isAuthenticated) return [];

    try {
      final response = await client
          .from('todos')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TodoItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching todos: $e');
      return [];
    }
  }

  // 할 일 추가
  Future<TodoItem?> addTodo(TodoItem item) async {
    if (!isAuthenticated) return null;

    try {
      final data = item.toJson();
      data['user_id'] = currentUser!.id;

      final response = await client
          .from('todos')
          .insert(data)
          .select()
          .single();

      return TodoItem.fromJson(response);
    } catch (e) {
      print('Error adding todo: $e');
      return null;
    }
  }

  // 할 일 업데이트
  Future<bool> updateTodo(TodoItem item) async {
    if (!isAuthenticated) return false;

    try {
      await client
          .from('todos')
          .update(item.toJson())
          .eq('id', item.id)
          .eq('user_id', currentUser!.id);

      return true;
    } catch (e) {
      print('Error updating todo: $e');
      return false;
    }
  }

  // 할 일 삭제
  Future<bool> deleteTodo(String id) async {
    if (!isAuthenticated) return false;

    try {
      await client
          .from('todos')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUser!.id);

      return true;
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }

  // 모든 할 일 삭제
  Future<bool> deleteAllTodos() async {
    if (!isAuthenticated) return false;

    try {
      await client
          .from('todos')
          .delete()
          .eq('user_id', currentUser!.id);

      return true;
    } catch (e) {
      print('Error deleting all todos: $e');
      return false;
    }
  }

  // 실시간 구독
  RealtimeChannel subscribeToTodos(Function(List<TodoItem>) onData) {
    return client
        .channel('todos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'todos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUser!.id,
          ),
          callback: (payload) async {
            final todos = await fetchTodos();
            onData(todos);
          },
        )
        .subscribe();
  }
}
