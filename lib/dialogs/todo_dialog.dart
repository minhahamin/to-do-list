import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoDialog extends StatefulWidget {
  final TodoItem? existingItem;
  final Function(TodoItem) onSave;

  const TodoDialog({
    super.key,
    this.existingItem,
    required this.onSave,
  });

  @override
  State<TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TodoCategory _selectedCategory;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingItem?.title ?? '');
    _notesController = TextEditingController(text: widget.existingItem?.notes ?? '');
    _selectedCategory = widget.existingItem?.category ?? TodoCategory.other;
    _selectedDueDate = widget.existingItem?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? Colors.grey[850] : Colors.white,
          gradient: isDark
              ? null
              : LinearGradient(
                  colors: [
                    Colors.deepPurple.shade50,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.existingItem != null ? Icons.edit : Icons.add_task,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.existingItem != null ? '할 일 수정' : '새로운 할 일',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 제목 입력
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '할 일',
                  hintText: '무엇을 해야 하나요?',
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.deepPurple.shade300, width: 2),
                  ),
                  prefixIcon: Icon(Icons.edit, color: Colors.deepPurple.shade300),
                ),
              ),
              const SizedBox(height: 16),
              // 카테고리 선택
              const Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TodoCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    label: Text(category.label),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: category.color,
                    backgroundColor: isDark
                        ? category.color.withOpacity(0.2)
                        : category.color.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : category.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // 마감일 선택
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.deepPurple.shade300,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '마감일',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedDueDate != null
                                  ? '${_selectedDueDate!.year}년 ${_selectedDueDate!.month}월 ${_selectedDueDate!.day}일'
                                  : '설정 안 함',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _selectedDueDate != null
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedDueDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty) return;

                      final item = TodoItem(
                        id: widget.existingItem?.id ?? DateTime.now().toString(),
                        title: _titleController.text,
                        isCompleted: widget.existingItem?.isCompleted ?? false,
                        category: _selectedCategory,
                        dueDate: _selectedDueDate,
                        notes: _notesController.text,
                        createdAt: widget.existingItem?.createdAt,
                      );

                      widget.onSave(item);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.existingItem != null ? '수정' : '추가'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
