import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/training_session.dart';
import '../session_store.dart';
import '../../training_type/models/training_type.dart';
import '../../training_type/training_type_store.dart';
import '../../training_type/widgets/training_type_form_sheet.dart';
import '../../focus/models/focus_point.dart';
import '../../focus/focus_store.dart';
import '../../focus/widgets/focus_point_form_sheet.dart';

class AddSessionPage extends StatefulWidget {
  const AddSessionPage({super.key});

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  double _focusScore = 5;
  double _frustrationScore = 3;
  double _fatigueScore = 4;

  TrainingType? _selectedTrainingType;
  FocusPoint? _selectedFocusPoint;

  bool _isSaving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showTrainingTypePicker() {
    final types = trainingTypeStore.all;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                  'Select Training Type',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (types.isEmpty)
                  _buildEmptyState(
                    context,
                    icon: Icons.sports,
                    message: 'No training types yet. Create one to get started.',
                    actionLabel: 'Create Training Type',
                    onAction: () {
                      Navigator.of(ctx).pop();
                      _showCreateTrainingTypeForm();
                    },
                  )
                else
                  ...types.map((type) {
                    return ListTile(
                      leading: type.icon != null
                          ? Icon(type.icon, color: type.color != null ? Color(type.color!) : null)
                          : const Icon(Icons.sports),
                      title: Text(type.name),
                      trailing: _selectedTrainingType?.id == type.id
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedTrainingType = type);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                if (types.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Create new type'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showCreateTrainingTypeForm();
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFocusPointPicker() {
    final points = focusStore.active;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                  'Select Focus Point',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (points.isEmpty)
                  _buildEmptyState(
                    context,
                    icon: Icons.center_focus_strong,
                    message: 'No active focus points. Create one to track your goals.',
                    actionLabel: 'Create Focus Point',
                    onAction: () {
                      Navigator.of(ctx).pop();
                      _showCreateFocusPointForm();
                    },
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.remove_circle_outline),
                    title: const Text('No focus point'),
                    trailing: _selectedFocusPoint == null
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedFocusPoint = null);
                      Navigator.of(ctx).pop();
                    },
                  ),
                  ...points.map((fp) {
                    return ListTile(
                      leading: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: fp.color != null ? Color(fp.color!) : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(fp.title),
                      trailing: _selectedFocusPoint?.id == fp.id
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedFocusPoint = fp);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ],
                if (points.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Create new focus point'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showCreateFocusPointForm();
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateTrainingTypeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const TrainingTypeFormSheet(),
    );
  }

  void _showCreateFocusPointForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FocusPointFormSheet(),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTrainingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a training type')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final session = TrainingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      trainingType: _selectedTrainingType,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
      focusPoint: _selectedFocusPoint,
      focusScore: _focusScore.round(),
      frustrationScore: _frustrationScore.round(),
      fatigueScore: _fatigueScore.round(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    sessionStore.add(session);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildScoreSlider(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.round()}/10',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: color,
          inactiveColor: color.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Session'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Session title',
                hintText: 'e.g. Morning HIIT',
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Training type picker
            InkWell(
              onTap: _showTrainingTypePicker,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Training type',
                  hintText: 'Select a training type',
                  prefixIcon: const Icon(Icons.sports),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTrainingType?.name ?? 'Select a training type',
                        style: TextStyle(
                          color: _selectedTrainingType != null
                              ? colorScheme.onSurface
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (_selectedTrainingType != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedTrainingType = null),
                        child: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'What did you do?',
                hintText: 'Describe your session...',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please describe the session';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Focus point picker
            InkWell(
              onTap: _showFocusPointPicker,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Focus point',
                  hintText: 'Select a focus point',
                  prefixIcon: const Icon(Icons.center_focus_strong),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedFocusPoint?.title ?? 'Select a focus point (optional)',
                        style: TextStyle(
                          color: _selectedFocusPoint != null
                              ? colorScheme.onSurface
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (_selectedFocusPoint != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedFocusPoint = null),
                        child: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Scores section
            Text(
              'How did it feel?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            _buildScoreSlider(
              'Focus on point',
              _focusScore,
              Colors.green,
              (v) => setState(() => _focusScore = v),
            ),
            _buildScoreSlider(
              'Frustration',
              _frustrationScore,
              Colors.orange,
              (v) => setState(() => _frustrationScore = v),
            ),
            _buildScoreSlider(
              'Fatigue',
              _fatigueScore,
              Colors.redAccent,
              (v) => setState(() => _fatigueScore = v),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Extra notes',
                hintText: 'Anything else worth remembering?',
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveSession,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Session',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
