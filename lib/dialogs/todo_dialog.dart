import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/todo_item.dart';
import '../services/ai_service.dart';

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
  late TextEditingController _linkController;
  late TodoCategory _selectedCategory;
  late RepeatType _selectedRepeat;
  late Priority _selectedPriority;
  DateTime? _selectedDueDate;
  List<String> _links = [];
  List<SubTask> _subTasks = [];
  bool _useAI = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingItem?.title ?? '');
    _notesController = TextEditingController(text: widget.existingItem?.notes ?? '');
    _linkController = TextEditingController();
    _selectedCategory = widget.existingItem?.category ?? TodoCategory.other;
    _selectedRepeat = widget.existingItem?.repeatType ?? RepeatType.none;
    _selectedPriority = widget.existingItem?.priority ?? Priority.medium;
    _selectedDueDate = widget.existingItem?.dueDate;
    _links = List.from(widget.existingItem?.links ?? []);
    _subTasks = List.from(widget.existingItem?.subTasks ?? []);
    
    _titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    if (_useAI && _titleController.text.isNotEmpty) {
      final suggestedCategory = AIService.suggestCategory(
        _titleController.text,
        _notesController.text,
      );
      if (suggestedCategory != _selectedCategory) {
        setState(() {
          _selectedCategory = suggestedCategory;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _linkController.dispose();
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
        // AI 우선순위 제안
        if (_useAI) {
          _selectedPriority = AIService.suggestPriority(_titleController.text, picked);
        }
      });
    }
  }

  void _addLink() {
    if (_linkController.text.trim().isNotEmpty) {
      setState(() {
        _links.add(_linkController.text.trim());
        _linkController.clear();
      });
    }
  }

  void _addSubTask() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('서브 태스크 추가'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '세부 작업 입력',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _subTasks.add(SubTask(
                      id: const Uuid().v4(),
                      title: controller.text.trim(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  // AI 자동 분류 토글
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, 
                        size: 16, 
                        color: _useAI ? Colors.amber : Colors.grey),
                      const SizedBox(width: 4),
                      Switch(
                        value: _useAI,
                        onChanged: (value) {
                          setState(() {
                            _useAI = value;
                          });
                        },
                        activeColor: Colors.amber,
                      ),
                    ],
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
              // 우선순위 선택
              Row(
                children: [
                  const Text('우선순위:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ...Priority.values.map((priority) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(priority.label),
                        selected: _selectedPriority == priority,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        selectedColor: priority.color.withOpacity(0.3),
                        avatar: Icon(
                          Icons.flag,
                          size: 16,
                          color: priority.color,
                        ),
                      ),
                    );
                  }),
                ],
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
              // 마감일과 반복 선택
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.deepPurple.shade300,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '마감일',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDueDate != null
                                  ? '${_selectedDueDate!.month}/${_selectedDueDate!.day}'
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                size: 16,
                                color: Colors.deepPurple.shade300,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '반복',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          DropdownButton<RepeatType>(
                            value: _selectedRepeat,
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            items: RepeatType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRepeat = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 메모 입력
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '상세한 내용을 입력하세요',
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
                  prefixIcon: Icon(Icons.notes, color: Colors.deepPurple.shade300),
                ),
              ),
              const SizedBox(height: 16),
              // 링크 추가
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        labelText: '링크 추가 (선택)',
                        hintText: 'https://...',
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
                        prefixIcon: Icon(Icons.link, color: Colors.deepPurple.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addLink,
                    icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                  ),
                ],
              ),
              if (_links.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_links.asMap().entries.map((entry) {
                  final index = entry.key;
                  final link = entry.value;
                  return Chip(
                    label: Text(
                      link.length > 30 ? '${link.substring(0, 30)}...' : link,
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _links.removeAt(index);
                      });
                    },
                  );
                })),
              ],
              const SizedBox(height: 16),
              // 서브 태스크
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '서브 태스크',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addSubTask,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('추가'),
                  ),
                ],
              ),
              if (_subTasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: _subTasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return CheckboxListTile(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _subTasks[index].isCompleted = value ?? false;
                          });
                        },
                        title: Text(task.title),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            setState(() {
                              _subTasks.removeAt(index);
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                        id: widget.existingItem?.id ?? const Uuid().v4(),
                        title: _titleController.text,
                        isCompleted: widget.existingItem?.isCompleted ?? false,
                        category: _selectedCategory,
                        dueDate: _selectedDueDate,
                        notes: _notesController.text.isEmpty 
                            ? null 
                            : _notesController.text,
                        links: _links.isEmpty ? null : _links,
                        subTasks: _subTasks.isEmpty ? null : _subTasks,
                        repeatType: _selectedRepeat,
                        priority: _selectedPriority,
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