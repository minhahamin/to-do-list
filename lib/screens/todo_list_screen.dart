import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import '../models/todo_item.dart';
import '../widgets/stat_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/todo_card.dart';
import '../widgets/voice_input_button.dart';
import '../dialogs/todo_dialog.dart';
import '../dialogs/stats_dialog.dart';
import '../providers/todo_provider.dart';
import '../services/supabase_service.dart';
import 'auth_screen.dart';
import 'package:uuid/uuid.dart';

class TodoListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const TodoListScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  SortType _currentSort = SortType.date;
  TodoCategory? _filterCategory;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 초기 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      if (provider.isAuthenticated) {
        provider.syncWithCloud();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TodoItem> _getFilteredAndSortedItems(List<TodoItem> items) {
    var filteredItems = items;

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) => item.matchesSearch(_searchQuery)).toList();
    }

    // 카테고리 필터
    if (_filterCategory != null) {
      filteredItems = filteredItems.where((item) => item.category == _filterCategory).toList();
    }

    // 정렬
    switch (_currentSort) {
      case SortType.date:
        filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.dueDate:
        filteredItems.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortType.category:
        filteredItems.sort((a, b) => a.category.label.compareTo(b.category.label));
        break;
      case SortType.completed:
        filteredItems.sort((a, b) => a.isCompleted ? 1 : -1);
        break;
    }

    return filteredItems;
  }

  void _showAddOrEditTodoDialog({TodoItem? editItem}) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TodoDialog(
          existingItem: editItem,
          onSave: (item) {
            if (editItem != null) {
              provider.updateTodo(editItem.id, item);
            } else {
              provider.addTodo(item);
            }
          },
        );
      },
    );
  }

  void _showStatsDialog() {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) => StatsDialog(todoItems: provider.todoItems),
    );
  }

  Future<void> _showBackupDialog() async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('백업 & 복원'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('JSON 내보내기'),
              onTap: () async {
                Navigator.pop(context);
                await _exportToJson(provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('JSON 가져오기'),
              onTap: () async {
                Navigator.pop(context);
                await _importFromJson(provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToJson(TodoProvider provider) async {
    try {
      final jsonString = provider.exportToJson();
      
      if (kIsWeb) {
        // 웹: 브라우저 다운로드
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'todos_backup.json')
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('백업 파일이 다운로드되었습니다'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('백업 실패: $e')),
        );
      }
    }
  }

  Future<void> _importFromJson(TodoProvider provider) async {
    try {
      if (kIsWeb) {
        // 웹: 파일 선택 대화상자
        final uploadInput = html.FileUploadInputElement()..accept = '.json';
        uploadInput.click();
        
        await uploadInput.onChange.first;
        final file = uploadInput.files!.first;
        final reader = html.FileReader();
        
        reader.readAsText(file);
        await reader.onLoad.first;
        
        final jsonString = reader.result as String;
        await provider.importFromJson(jsonString);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('복원 완료!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 실패: $e')),
        );
      }
    }
  }

  Future<void> _showAccountMenu() async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final supabase = SupabaseService();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.isAuthenticated) ...[
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(supabase.currentUser?.email ?? '사용자'),
                subtitle: const Text('로그인됨'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('수동 동기화'),
                onTap: () {
                  Navigator.pop(context);
                  provider.syncWithCloud();
                },
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('백업 & 복원'),
                onTap: () {
                  Navigator.pop(context);
                  _showBackupDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Provider 초기화
                  provider.clearAllTodos();
                  
                  // 로그아웃
                  await supabase.signOut();
                  
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => AuthScreen(
                          onToggleTheme: widget.onToggleTheme,
                          themeMode: widget.themeMode,
                        ),
                      ),
                    );
                  }
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('로그인'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => AuthScreen(
                        onToggleTheme: widget.onToggleTheme,
                        themeMode: widget.themeMode,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('백업 & 복원'),
                onTap: () {
                  Navigator.pop(context);
                  _showBackupDialog();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final allItems = provider.todoItems;
        final filteredItems = _getFilteredAndSortedItems(allItems);
        
        final completedCount = allItems.where((item) => item.isCompleted).length;
        final totalCount = allItems.length;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
        final todayTasks = allItems.where((item) => item.isDueToday).length;
        final overdueTasks = allItems.where((item) => item.isOverdue).length;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.deepPurple.shade900,
                        Colors.deepPurple.shade700,
                        Colors.pink.shade900,
                      ]
                    : [
                        Colors.deepPurple.shade400,
                        Colors.deepPurple.shade200,
                        Colors.pink.shade100,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark, provider, completedCount, totalCount, progress, todayTasks, overdueTasks),
                  _buildTodoList(isDark, provider, filteredItems),
                ],
              ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 음성 입력 버튼
              if (kIsWeb)
                VoiceInputButton(
                  onText: (text) {
                    final item = TodoItem(
                      id: const Uuid().v4(),
                      title: text,
                      category: TodoItem.suggestCategory(text, null),
                    );
                    provider.addTodo(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('추가됨: $text')),
                    );
                  },
                ),
              if (kIsWeb) const SizedBox(height: 12),
              // 일반 추가 버튼
              FloatingActionButton.extended(
                heroTag: 'add_button',  // Hero 태그 중복 방지
                onPressed: () => _showAddOrEditTodoDialog(),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('추가'),
                elevation: 6,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, TodoProvider provider, int completedCount, int totalCount, double progress, int todayTasks, int overdueTasks) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(isDark, provider),
          if (_isSearching) ...[
            const SizedBox(height: 16),
            _buildSearchBar(),
          ],
          const SizedBox(height: 16),
          _buildStatsCards(completedCount, totalCount, progress, todayTasks, overdueTasks, isDark),
          const SizedBox(height: 16),
          _buildCategoryFilters(isDark),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, TodoProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '나의 할 일',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (!provider.isOnline) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
        Row(
          children: [
            // 로그인 여부와 상관없이 프로필 메뉴 표시
            _buildIconButton(
              provider.isAuthenticated ? Icons.person : Icons.login,
              _showAccountMenu,
            ),
            _buildIconButton(Icons.analytics, _showStatsDialog),
            _buildIconButton(
              _isSearching ? Icons.close : Icons.search,
              () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
            ),
            _buildSortButton(),
            _buildIconButton(
              isDark ? Icons.light_mode : Icons.dark_mode,
              widget.onToggleTheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<SortType>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.sort, color: Colors.white),
      ),
      onSelected: (SortType result) {
        setState(() {
          _currentSort = result;
        });
      },
      itemBuilder: (BuildContext context) => SortType.values
          .map((type) => PopupMenuItem<SortType>(
                value: type,
                child: Row(
                  children: [
                    if (_currentSort == type) const Icon(Icons.check, size: 18),
                    if (_currentSort == type) const SizedBox(width: 8),
                    Text(type.label),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: '할 일 검색...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildStatsCards(int completedCount, int totalCount, double progress, int todayTasks, int overdueTasks, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: '완료',
            value: '$completedCount/$totalCount',
            icon: Icons.check_circle,
            color: Colors.green,
            progress: progress,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: '오늘',
            value: '$todayTasks',
            icon: Icons.today,
            color: Colors.blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: '지연',
            value: '$overdueTasks',
            icon: Icons.warning,
            color: Colors.red,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryChip(
            category: null,
            label: '전체',
            icon: Icons.apps,
            isDark: isDark,
            isSelected: _filterCategory == null,
            onTap: () {
              setState(() {
                _filterCategory = null;
              });
            },
          ),
          ...TodoCategory.values.map(
            (category) => CategoryChip(
              category: category,
              label: category.label,
              icon: category.icon,
              isDark: isDark,
              isSelected: _filterCategory == category,
              onTap: () {
                setState(() {
                  _filterCategory = category;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(bool isDark, TodoProvider provider, List<TodoItem> filteredItems) {
    // 필터링/정렬이 활성화되어 있는지 확인
    final isFiltered = _searchQuery.isNotEmpty || _filterCategory != null;
    final isSorted = _currentSort != SortType.date;
    final canReorder = !isFiltered && !isSorted;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredItems.isEmpty
                ? _buildEmptyState(isDark)
                : Column(
                    children: [
                      // 순서 변경 불가 안내
                      if (!canReorder && filteredItems.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, 
                                color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '검색/필터/정렬 중에는 순서를 변경할 수 없습니다',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: canReorder
                            ? ReorderableListView.builder(
                                itemCount: filteredItems.length,
                                padding: const EdgeInsets.all(16),
                                onReorder: (oldIndex, newIndex) {
                                  provider.reorderTodos(oldIndex, newIndex);
                                },
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return TodoCard(
                                    key: Key(item.id),
                                    item: item,
                                    isDark: isDark,
                                    index: index,
                                    onToggle: () => provider.toggleTodo(item.id),
                                    onDelete: () {
                                      provider.deleteTodo(item.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('할 일이 삭제되었습니다'),
                                          action: SnackBarAction(
                                            label: '취소',
                                            onPressed: () {
                                              provider.addTodo(item);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    onEdit: () => _showAddOrEditTodoDialog(editItem: item),
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: filteredItems.length,
                                padding: const EdgeInsets.all(16),
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return Container(
                                    key: Key(item.id),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: TodoCard(
                                      item: item,
                                      isDark: isDark,
                                      index: -1, // 드래그 핸들 숨기기
                                      onToggle: () => provider.toggleTodo(item.id),
                                      onDelete: () {
                                        provider.deleteTodo(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('할 일이 삭제되었습니다'),
                                            action: SnackBarAction(
                                              label: '취소',
                                              onPressed: () {
                                                provider.addTodo(item);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      onEdit: () => _showAddOrEditTodoDialog(editItem: item),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.task_alt,
            size: 100,
            color: Colors.deepPurple.shade100,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? '검색 결과가 없습니다'
                : _filterCategory != null
                    ? '이 카테고리에 할 일이 없습니다'
                    : '할 일이 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? '다른 검색어를 시도해보세요'
                : '아래 버튼을 눌러 추가해보세요!',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}