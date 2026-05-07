import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../theme/app_theme.dart';
import 'topic_list_screen.dart';

class SubjectListScreen extends ConsumerWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Subjects'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildInsightsCard(ref),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  Text('${subjects.length} total', style: const TextStyle(color: Colors.black38, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          subjects.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _SubjectListItem(subject: subjects[index]),
                    ),
                    childCount: subjects.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Subject'),
      ),
    );
  }

  Widget _buildInsightsCard(WidgetRef ref) {
    final topics = ref.watch(topicsProvider);
    final totalHours = topics.fold(0.0, (sum, t) => sum + t.estimatedHours);
    final doneHours = topics.where((t) => t.status == TopicStatus.completed).fold(0.0, (sum, t) => sum + t.estimatedHours);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learning Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              _InsightItem(label: 'Total effort', value: '${totalHours.toInt()}h', icon: Icons.timer_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              _InsightItem(label: 'Completed', value: '${doneHours.toInt()}h', icon: Icons.auto_graph_rounded, color: const Color(0xFF10B981)),
              const SizedBox(width: 12),
              _InsightItem(label: 'Remaining', value: '${(totalHours - doneHours).toInt()}h', icon: Icons.pending_actions_rounded, color: Colors.orange),
            ],
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
          Icon(Icons.library_books_rounded, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('Organize your curriculum here', style: TextStyle(color: Colors.black26)),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    int selectedColorValue = AppTheme.primaryColor.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Subject Title',
                  filled: true, fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              const Text('Pick a Color', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _ColorPicker(onColorSelected: (color) => setModalState(() => selectedColorValue = color.value)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      ref.read(subjectsProvider.notifier).addSubject(Subject(id: const Uuid().v4(), name: nameController.text, colorValue: selectedColorValue, createdAt: DateTime.now()));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Subject'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _InsightItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.black45, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SubjectListItem extends ConsumerWidget {
  final Subject subject;
  const _SubjectListItem({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider).where((t) => t.subjectId == subject.id).toList();
    final completedTopics = topics.where((t) => t.status == TopicStatus.completed).length;
    final progress = topics.isEmpty ? 0.0 : completedTopics / topics.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TopicListScreen(subject: subject))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: Color(subject.colorValue).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.menu_book_rounded, color: Color(subject.colorValue), size: 20)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textColor)),
                        Text('${topics.length} topics • ${(topics.fold(0.0, (sum, t) => sum + t.estimatedHours)).toInt()}h total', style: const TextStyle(color: Colors.black38, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.black26),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Color(subject.colorValue).withOpacity(0.05), valueColor: AlwaysStoppedAnimation(Color(subject.colorValue))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatefulWidget {
  final Function(Color) onColorSelected;
  const _ColorPicker({required this.onColorSelected});
  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  final List<Color> colors = [const Color(0xFF4F46E5), const Color(0xFF7C3AED), const Color(0xFFEC4899), const Color(0xFFF59E0B), const Color(0xFF10B981), const Color(0xFF0EA5E9)];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(colors.length, (index) => GestureDetector(onTap: () { setState(() => selectedIndex = index); widget.onColorSelected(colors[index]); }, child: Container(width: 36, height: 36, decoration: BoxDecoration(color: colors[index], shape: BoxShape.circle, border: selectedIndex == index ? Border.all(color: Colors.black, width: 2) : null)))));
  }
}
