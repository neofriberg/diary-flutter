import 'package:flutter/material.dart';

import '../../data/models/diary_entry.dart';
import '../../data/repositories/diary_repository.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DiaryRepository _repository = InMemoryDiaryRepository();

  @override
  Widget build(BuildContext context) {
    final entries = _repository.getAllEntries();

    return Scaffold(
      body: Center(
        child: entries.isEmpty
            ? const Text('Hello World')
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.content),
                  );
                },
              ),
      ),
    );
  }
}
