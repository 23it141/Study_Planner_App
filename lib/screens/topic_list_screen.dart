import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../providers/topic_provider.dart';
import '../theme/app_theme.dart';

class TopicListScreen extends ConsumerWidget {
  final Subject subject;
  const TopicListScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider).where((t) => t.subjectId == subject.id).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(subject.name),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSubjectHeader(topics),
          Expanded(
            child: topics.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      return _TopicCard(topic: topics[index], color: Color(subject.colorValue));
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTopicDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubjectHeader(List<Topic> topics) {
    final completed = topics.where((t) => t.status == TopicStatus.completed).length;
    final progress = topics.isEmpty ? 0.0 : completed / topics.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${topics.length} Topics', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
              Text('${(progress * 100).toInt()}% Done', style: TextStyle(fontWeight: FontWeight.bold, color: Color(subject.colorValue))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Color(subject.colorValue).withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation(Color(subject.colorValue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.note_add_rounded, size: 64, color: Colors.black12),
          const SizedBox(height: 16),
          const Text('No topics added yet', style: TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final timeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Topic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Topic Name',
                filled: true, fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Est. Hours',
                filled: true, fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final topic = Topic(
                      id: const Uuid().v4(),
                      subjectId: subject.id,
                      name: nameController.text,
                      estimatedHours: double.tryParse(timeController.text) ?? 1.0,
                      status: TopicStatus.notStarted,
                      createdAt: DateTime.now(),
                    );
                    ref.read(topicsProvider.notifier).addTopic(topic);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Topic'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends ConsumerWidget {
  final Topic topic;
  final Color color;
  const _TopicCard({required this.topic, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: _StatusToggle(topic: topic, color: color),
        title: Row(
          children: [
            Expanded(
              child: Text(
                topic.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: topic.status == TopicStatus.completed ? TextDecoration.lineThrough : null,
                  color: topic.status == TopicStatus.completed ? Colors.black38 : AppTheme.textColor,
                ),
              ),
            ),
            if (topic.status == TopicStatus.inProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('LEARNING', style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Text('${topic.estimatedHours}h estimated', style: const TextStyle(fontSize: 12, color: Colors.black45)),
        trailing: PopupMenuButton<TopicStatus>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.black26),
          onSelected: (status) {
            if (status != null) ref.read(topicsProvider.notifier).updateTopic(topic.copyWith(status: status));
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: TopicStatus.notStarted, child: Text('Not Started')),
            const PopupMenuItem(value: TopicStatus.inProgress, child: Text('In Progress')),
            const PopupMenuItem(value: TopicStatus.completed, child: Text('Completed')),
            const PopupMenuItem(value: null, child: Divider()),
            PopupMenuItem(onTap: () => ref.read(topicsProvider.notifier).deleteTopic(topic.id), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}

class _StatusToggle extends ConsumerWidget {
  final Topic topic;
  final Color color;
  const _StatusToggle({required this.topic, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final nextStatus = topic.status == TopicStatus.completed ? TopicStatus.notStarted : TopicStatus.completed;
        ref.read(topicsProvider.notifier).updateTopic(topic.copyWith(status: nextStatus));
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: topic.status == TopicStatus.completed ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: topic.status == TopicStatus.completed ? color : Colors.black12, width: 2),
        ),
        child: Icon(
          Icons.check,
          size: 16,
          color: topic.status == TopicStatus.completed ? Colors.white : Colors.transparent,
        ),
      ),
    );
  }
}
