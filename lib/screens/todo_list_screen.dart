import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../widgets/stat_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/todo_card.dart';
import '../dialogs/todo_dialog.dart';
import '../dialogs/stats_dialog.dart';

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
  final List<TodoItem> _todoItems = [];
  SortType _currentSort = SortType.date;
  TodoCategory? _filterCategory;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TodoItem> get _filteredAndSortedItems {
    var items = _todoItems;

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) => item.matchesSearch(_searchQuery)).toList();
    }

    // 카테고리 필터
    if (_filterCategory != null) {
      items = items.where((item) => item.category == _filterCategory).toList();
    }

    // 정렬
    switch (_currentSort) {
      case SortType.date:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.dueDate:
        items.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortType.category:
        items.sort((a, b) => a.category.label.compareTo(b.category.label));
        break;
      case SortType.completed:
        items.sort((a, b) => a.isCompleted ? 1 : -1);
        break;
    }

    return items;
  }

  void _addTodoItem(TodoItem item) {
    setState(() {
      _todoItems.add(item);
    });
  }

  void _updateTodoItem(String id, TodoItem updatedItem) {
    setState(() {
      final index = _todoItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _todoItems[index] = updatedItem;
      }
    });
  }

  void _toggleTodoItem(String id) {
    setState(() {
      final index = _todoItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
      }
    });
  }

  void _deleteTodoItem(String id) {
    setState(() {
      _todoItems.removeWhere((item) => item.id == id);
    });
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _filteredAndSortedItems.removeAt(oldIndex);
      _filteredAndSortedItems.insert(newIndex, item);
      _todoItems.clear();
      _todoItems.addAll(_filteredAndSortedItems);
    });
  }

  void _showAddOrEditTodoDialog({TodoItem? editItem}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TodoDialog(
          existingItem: editItem,
          onSave: (item) {
            if (editItem != null) {
              _updateTodoItem(editItem.id, item);
            } else {
              _addTodoItem(item);
            }
          },
        );
      },
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => StatsDialog(todoItems: _todoItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = _todoItems.where((item) => item.isCompleted).length;
    final totalCount = _todoItems.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final todayTasks = _todoItems.where((item) => item.isDueToday).length;
    final overdueTasks = _todoItems.where((item) => item.isOverdue).length;

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
              _buildHeader(isDark, completedCount, totalCount, progress, todayTasks, overdueTasks),
              _buildTodoList(isDark),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditTodoDialog(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('추가'),
        elevation: 6,
      ),
    );
  }

  Widget _buildHeader(bool isDark, int completedCount, int totalCount, double progress, int todayTasks, int overdueTasks) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(isDark),
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

  Widget _buildTopBar(bool isDark) {
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
            Text(
              '${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        Row(
          children: [
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

  Widget _buildTodoList(bool isDark) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _filteredAndSortedItems.isEmpty
            ? _buildEmptyState(isDark)
            : ReorderableListView.builder(
                itemCount: _filteredAndSortedItems.length,
                padding: const EdgeInsets.all(16),
                onReorder: _reorderItems,
                itemBuilder: (context, index) {
                  final item = _filteredAndSortedItems[index];
                  return TodoCard(
                    key: Key(item.id),
                    item: item,
                    isDark: isDark,
                    index: index,
                    onToggle: () => _toggleTodoItem(item.id),
                    onDelete: () {
                      _deleteTodoItem(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('할 일이 삭제되었습니다'),
                          action: SnackBarAction(
                            label: '취소',
                            onPressed: () {
                              setState(() {
                                _todoItems.add(item);
                              });
                            },
                          ),
                        ),
                      );
                    },
                    onEdit: () => _showAddOrEditTodoDialog(editItem: item),
                  );
                },
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
