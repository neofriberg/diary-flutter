import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/focus_point.dart';
import '../focus_store.dart';
import '../widgets/focus_point_form_sheet.dart';

class ManageFocusPointsPage extends StatefulWidget {
  const ManageFocusPointsPage({super.key});

  @override
  State<ManageFocusPointsPage> createState() => _ManageFocusPointsPageState();
}

class _ManageFocusPointsPageState extends State<ManageFocusPointsPage> {
  bool _showArchived = false;

  void _showForm(BuildContext context, {FocusPoint? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FocusPointFormSheet(existing: existing),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Focus Point'),
        content: Text('Are you sure you want to delete "$title"? Sessions linked to it will lose their focus.'),
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
        title: const Text('Focus Points'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Active')),
                ButtonSegment(value: true, label: Text('All')),
              ],
              selected: {_showArchived},
              onSelectionChanged: (sel) {
                setState(() => _showArchived = sel.first);
              },
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: focusStore,
        builder: (context, _) {
          final all = focusStore.all;
          final items = _showArchived
              ? all
              : all.where((e) => e.isActive).toList();
          if (items.isEmpty) {
            return const Center(
              child: Text('No focus points yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final fp = items[index];
              final isActiveNow = fp.isCurrentlyActive;
              return Dismissible(
                key: ValueKey(fp.id),
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
                confirmDismiss: (_) => _confirmDelete(context, fp.title),
                onDismissed: (_) => focusStore.remove(fp.id),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: fp.color != null
                          ? Color(fp.color!).withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: fp.color != null
                          ? Icon(Icons.flag, color: Color(fp.color!))
                          : Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(fp.title),
                    subtitle: Text(
                      '${DateFormat('d MMM').format(fp.startDate)} – ${DateFormat('d MMM yyyy').format(fp.endDate)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActiveNow)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: fp.color != null ? Color(fp.color!) : Colors.green,
                              shape: BoxShape.circle,
                            ),
                          )
                        else if (!fp.isActive)
                          const Icon(Icons.archive_outlined, size: 18, color: Colors.grey)
                        else
                          const Icon(Icons.circle, size: 10, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _showForm(context, existing: fp),
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
