import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/id_generator.dart';
import '../models/focus_point.dart';
import '../focus_store.dart';

const List<int> _kPresetColors = [
  0xFFE53935,
  0xFFD81B60,
  0xFF8E24AA,
  0xFF5E35B1,
  0xFF3949AB,
  0xFF1E88E5,
  0xFF00897B,
  0xFF43A047,
  0xFF7CB342,
  0xFFFBC02D,
  0xFFFF6F00,
  0xFF6D4C41,
  0xFF757575,
  0xFF00ACC1,
  0xFF26C6DA,
];

class FocusPointFormSheet extends StatefulWidget {
  final FocusPoint? existing;

  const FocusPointFormSheet({super.key, this.existing});

  @override
  State<FocusPointFormSheet> createState() => _FocusPointFormSheetState();
}

class _FocusPointFormSheetState extends State<FocusPointFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 28));
  bool _isActive = true;
  int? _selectedColor;
  int _durationWeeks = 4;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _descriptionController.text = widget.existing!.description ?? '';
      _startDate = widget.existing!.startDate;
      _endDate = widget.existing!.endDate;
      _isActive = widget.existing!.isActive;
      _selectedColor = widget.existing!.color;
      _durationWeeks = _endDate.difference(_startDate).inDays ~/ 7;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _endDate = _startDate.add(Duration(days: _durationWeeks * 7));
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _updateDuration(int weeks) {
    setState(() {
      _durationWeeks = weeks;
      _endDate = _startDate.add(Duration(days: weeks * 7));
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('Title is required');
      return;
    }
    if (_endDate.isBefore(_startDate) || _endDate == _startDate) {
      _showError('End date must be after start date');
      return;
    }
    if (focusStore.titleExists(title, excludeId: widget.existing?.id)) {
      _showError('An active focus point with this title already exists');
      return;
    }

    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        title: title,
        description: description,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        color: _selectedColor,
        updatedAt: DateTime.now(),
      );
      focusStore.update(updated);
    } else {
      final entity = FocusPoint(
        id: generateId(),
        title: title,
        description: description,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        color: _selectedColor,
        createdAt: DateTime.now(),
      );
      focusStore.add(entity);
    }
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing != null ? 'Edit Focus Point' : 'New Focus Point',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Improve running cadence',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'What are you trying to achieve?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: true),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Start date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(DateFormat('d MMM yyyy').format(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: false),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'End date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(DateFormat('d MMM yyyy').format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Duration: $_durationWeeks weeks',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Slider(
                value: _durationWeeks.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$_durationWeeks weeks',
                onChanged: (v) => _updateDuration(v.round()),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Colour',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _kPresetColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(color).withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
