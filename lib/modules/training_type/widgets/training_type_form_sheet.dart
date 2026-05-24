import 'package:flutter/material.dart';

import '../../../core/utils/id_generator.dart';
import '../models/training_type.dart';
import '../training_type_store.dart';

/// A curated set of Material icons for training types.
const List<IconData> _kTrainingIcons = [
  Icons.fitness_center,
  Icons.directions_run,
  Icons.pool,
  Icons.pedal_bike,
  Icons.self_improvement,
  Icons.sports_basketball,
  Icons.sports_volleyball,
  Icons.kayaking,
  Icons.hiking,
  Icons.directions_walk,
  Icons.accessibility_new,
  Icons.spa,
  Icons.local_fire_department,
  Icons.water,
  Icons.sports_gymnastics,
  Icons.surfing,
];

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

class TrainingTypeFormSheet extends StatefulWidget {
  final TrainingType? existing;

  const TrainingTypeFormSheet({super.key, this.existing});

  @override
  State<TrainingTypeFormSheet> createState() => _TrainingTypeFormSheetState();
}

class _TrainingTypeFormSheetState extends State<TrainingTypeFormSheet> {
  final _nameController = TextEditingController();
  IconData? _selectedIcon;
  int? _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _selectedIcon = widget.existing!.icon;
      _selectedColor = widget.existing!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Name is required');
      return;
    }
    if (trainingTypeStore.nameExists(name, excludeId: widget.existing?.id)) {
      _showError('A training type with this name already exists');
      return;
    }

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        name: name,
        iconCodePoint: _selectedIcon?.codePoint,
        color: _selectedColor,
      );
      trainingTypeStore.update(updated);
    } else {
      final entity = TrainingType(
        id: generateId(),
        name: name,
        iconCodePoint: _selectedIcon?.codePoint,
        color: _selectedColor,
        createdAt: DateTime.now(),
      );
      trainingTypeStore.add(entity);
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
        child: Padding(
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
                widget.existing != null ? 'Edit Training Type' : 'New Training Type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Trail Running',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Icon',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kTrainingIcons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
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
