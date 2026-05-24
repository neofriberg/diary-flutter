import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../training_type/models/training_type.dart';
import '../../training_type/training_type_store.dart';
import '../../training_type/pages/manage_training_types_page.dart';
import '../../training_type/widgets/training_type_form_sheet.dart';
import '../../focus/models/focus_point.dart';
import '../../focus/focus_store.dart';
import '../../focus/pages/manage_focus_page.dart';
import '../../focus/widgets/focus_point_form_sheet.dart';
import '../profile_store.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showTrainingTypeForm(BuildContext context, {TrainingType? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TrainingTypeFormSheet(existing: existing),
    );
  }

  void _showFocusPointForm(BuildContext context, {FocusPoint? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FocusPointFormSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Profile'),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  AnimatedBuilder(
                    animation: profileStore,
                    builder: (context, _) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  size: 32,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profileStore.profile?.displayName ??
                                          'Athlete',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Keep building consistency',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Training Types Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Training Types',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ManageTrainingTypesPage(),
                                ),
                              );
                            },
                            child: const Text('Show all'),
                          ),
                          IconButton(
                            onPressed: () => _showTrainingTypeForm(context),
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add training type',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: trainingTypeStore,
                    builder: (context, _) {
                      final types = trainingTypeStore.all;
                      if (types.isEmpty) {
                        return Card(
                          color: Colors.grey[50],
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey[500]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No training types yet. Create one to get started.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: types.length,
                          itemBuilder: (context, index) {
                            final type = types[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < types.length - 1 ? 10 : 0,
                              ),
                              child: ActionChip(
                                avatar: type.icon != null
                                    ? Icon(type.icon, size: 18)
                                    : null,
                                label: Text(type.name),
                                backgroundColor: type.color != null
                                    ? Color(type.color!).withValues(alpha: 0.1)
                                    : colorScheme.surfaceContainerHighest,
                                side: BorderSide.none,
                                onPressed: () => _showTrainingTypeForm(context, existing: type),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Focus Points Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Focus Points',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ManageFocusPointsPage(),
                                ),
                              );
                            },
                            child: const Text('Show all'),
                          ),
                          IconButton(
                            onPressed: () => _showFocusPointForm(context),
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add focus point',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: focusStore,
                    builder: (context, _) {
                      final points = focusStore.active;
                      if (points.isEmpty) {
                        return Card(
                          color: Colors.grey[50],
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey[500]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No active focus points. Create one to track your goals.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: points.map((fp) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                leading: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: fp.color != null
                                        ? Color(fp.color!)
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(fp.title),
                                subtitle: Text(
                                  '${DateFormat('d MMM').format(fp.startDate)} – ${DateFormat('d MMM yyyy').format(fp.endDate)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _showFocusPointForm(context, existing: fp),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
