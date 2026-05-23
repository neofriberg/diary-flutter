import 'package:flutter/material.dart';

import '../models/training_type.dart';
import '../training_type_store.dart';
import '../widgets/training_type_form_sheet.dart';

class ManageTrainingTypesPage extends StatelessWidget {
  const ManageTrainingTypesPage({super.key});

  void _showForm(BuildContext context, {TrainingType? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TrainingTypeFormSheet(existing: existing),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Training Type'),
        content: Text('Are you sure you want to delete "$name"? Sessions using this type will become uncategorised.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Types'),
      ),
      body: AnimatedBuilder(
        animation: trainingTypeStore,
        builder: (context, _) {
          final items = trainingTypeStore.all;
          if (items.isEmpty) {
            return const Center(
              child: Text('No training types yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final type = items[index];
              return Dismissible(
                key: ValueKey(type.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(context, type.name),
                onDismissed: (_) => trainingTypeStore.remove(type.id),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: type.color != null
                          ? Color(type.color!).withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: type.icon != null
                          ? Icon(type.icon, color: type.color != null ? Color(type.color!) : Theme.of(context).colorScheme.primary)
                          : Icon(Icons.sports, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(type.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showForm(context, existing: type),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
