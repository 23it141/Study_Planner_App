import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/study_session.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../providers/session_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final subjects = ref.watch(subjectsProvider);

    final sortedSessions = [...sessions]..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final weeklySessions = sessions.where((s) => s.startTime.isAfter(startOfWeek) && s.startTime.isBefore(endOfWeek)).toList();
    final weeklyHours = weeklySessions.fold(0, (sum, s) => sum + s.durationMinutes) / 60.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Study Plan'), elevation: 0, backgroundColor: Colors.transparent),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildWeeklySummary(weeklyHours, weeklySessions.length),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Sessions (${sortedSessions.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          sortedSessions.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = sortedSessions[index];
                      final subject = subjects.firstWhere(
                        (s) => s.id == session.subjectId,
                        orElse: () => Subject(id: '', name: 'Unknown', colorValue: Colors.grey.value, createdAt: DateTime.now()),
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _SessionCard(session: session, subject: subject),
                      );
                    },
                    childCount: sortedSessions.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSessionDialog(context, ref),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('New Session'),
      ),
    );
  }

  Widget _buildWeeklySummary(double hours, int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Commitment', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${hours.toStringAsFixed(1)}h', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Text('$count Sessions', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Planning ahead reduces anxiety and boosts productivity!', style: TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('No sessions planned for this week', style: TextStyle(color: Colors.black26)),
        ],
      ),
    );
  }

  void _showAddSessionDialog(BuildContext context, WidgetRef ref) {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a subject first')));
      return;
    }

    String? selectedSubjectId;
    String? selectedTopicId;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int duration = 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final topics = selectedSubjectId == null ? <Topic>[] : ref.read(topicsProvider).where((t) => t.subjectId == selectedSubjectId).toList();

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plan Study Session', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedSubjectId,
                  decoration: const InputDecoration(labelText: 'Select Subject'),
                  items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (val) => setModalState(() {
                    selectedSubjectId = val;
                    selectedTopicId = null;
                  }),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTopicId,
                  decoration: const InputDecoration(labelText: 'Select Topic'),
                  items: topics.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (val) => setModalState(() => selectedTopicId = val),
                  hint: const Text('Choose a topic'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DateTimePickerTile(
                        label: 'Date',
                        value: DateFormat('MMM dd, yyyy').format(selectedDate),
                        onTap: () async {
                          final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (date != null) setModalState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DateTimePickerTile(
                        label: 'Time',
                        value: selectedTime.format(context),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: selectedTime);
                          if (time != null) setModalState(() => selectedTime = time);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Duration', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('$duration min', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ],
                ),
                Slider(
                  value: duration.toDouble(),
                  min: 15, max: 240, divisions: 15,
                  onChanged: (val) => setModalState(() => duration = val.toInt()),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedSubjectId != null && selectedTopicId != null)
                        ? () {
                            final startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                            ref.read(sessionsProvider.notifier).addSession(StudySession(id: const Uuid().v4(), subjectId: selectedSubjectId!, topicId: selectedTopicId!, startTime: startTime, durationMinutes: duration));
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Schedule Now'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateTimePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateTimePickerTile({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final StudySession session;
  final Subject subject;
  const _SessionCard({required this.session, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = ref.watch(topicsProvider).firstWhere(
          (t) => t.id == session.topicId,
          orElse: () => Topic(id: '', subjectId: '', name: 'Deleted Topic', estimatedHours: 0, status: TopicStatus.notStarted, createdAt: DateTime.now()),
        );

    final isPast = session.startTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: Color(subject.colorValue).withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(session.startTime).toUpperCase(), style: TextStyle(color: Color(subject.colorValue), fontWeight: FontWeight.w800, fontSize: 9)),
                  Text(DateFormat('dd').format(session.startTime), style: TextStyle(color: Color(subject.colorValue), fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subject.name, style: TextStyle(color: Color(subject.colorValue), fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text('${DateFormat('hh:mm a').format(session.startTime)} • ${session.durationMinutes}m', style: const TextStyle(color: Colors.black38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            if (!isPast)
              IconButton(onPressed: () => ref.read(sessionsProvider.notifier).deleteSession(session.id), icon: const Icon(Icons.close_rounded, color: Colors.black12, size: 18)),
          ],
        ),
      ),
    );
  }
}
