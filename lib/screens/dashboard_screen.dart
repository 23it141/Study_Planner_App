import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../providers/session_provider.dart';
import '../models/topic.dart';
import '../models/subject.dart';
import '../models/study_session.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);
    final sessions = ref.watch(sessionsProvider);

    final completedTopics = topics.where((t) => t.status == TopicStatus.completed).length;
    final progress = topics.isEmpty ? 0.0 : completedTopics / topics.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: const Text('Study Dashboard', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w800, fontSize: 24)),
              background: Container(color: AppTheme.backgroundColor),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProgressOverview(progress),
                const SizedBox(height: 32),
                _buildMotivationalQuote(),
                const SizedBox(height: 32),
                const Text('Preparation Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 16),
                _buildStatsGrid(subjects.length, completedTopics, topics.length - completedTopics),
                const SizedBox(height: 32),
                const Text('Smart Suggestion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 16),
                _buildSmartSuggestion(ref),
                const SizedBox(height: 32),
                const Text('Study Tip of the Day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 16),
                _buildStudyTip(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                    TextButton(onPressed: () {}, child: const Text('View History')),
                  ],
                ),
                _buildRecentSessions(sessions, subjects),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: const Column(
        children: [
          Icon(Icons.format_quote_rounded, color: AppTheme.primaryColor, size: 32),
          SizedBox(height: 8),
          Text(
            '"The secret of getting ahead is getting started."',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: AppTheme.textColor),
          ),
          SizedBox(height: 4),
          Text('- Mark Twain', style: TextStyle(fontSize: 12, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildStudyTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: const Row(
        children: [
          CircleAvatar(backgroundColor: Color(0xFFF0FDF4), child: Icon(Icons.psychology_rounded, color: Color(0xFF10B981))),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pomodoro Technique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Study for 25 mins, take a 5 min break. It helps keep your focus sharp!', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Progress', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}% Completed',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Consistency is the key to success!',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int subjects, int completed, int pending) {
    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Subjects', value: '$subjects', color: AppTheme.primaryColor, icon: Icons.book_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _StatTile(label: 'Done', value: '$completed', color: const Color(0xFF10B981), icon: Icons.check_circle_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _StatTile(label: 'Pending', value: '$pending', color: Colors.orange, icon: Icons.pending_rounded)),
      ],
    );
  }

  Widget _buildSmartSuggestion(WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    if (subjects.isEmpty || topics.isEmpty) {
      return const _EmptyCard(message: 'Add topics to get smart focus suggestions');
    }

    String? prioritySubjectId;
    double lowestCompletion = 1.1;

    for (var s in subjects) {
      final sTopics = topics.where((t) => t.subjectId == s.id).toList();
      if (sTopics.isEmpty) continue;
      final completion = sTopics.where((t) => t.status == TopicStatus.completed).length / sTopics.length;
      if (completion < lowestCompletion) {
        lowestCompletion = completion;
        prioritySubjectId = s.id;
      }
    }

    if (prioritySubjectId == null) return const _EmptyCard(message: 'All topics completed!');

    final prioritySubject = subjects.firstWhere((s) => s.id == prioritySubjectId);
    final nextTopic = topics.firstWhere(
      (t) => t.subjectId == prioritySubjectId && t.status != TopicStatus.completed,
      orElse: () => topics.firstWhere((t) => t.subjectId == prioritySubjectId),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study ${nextTopic.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textColor),
                ),
                Text('Next up in ${prioritySubject.name}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(List<StudySession> sessions, List<Subject> subjects) {
    if (sessions.isEmpty) return const Padding(padding: EdgeInsets.only(top: 16), child: Text('No study history yet', style: TextStyle(color: Colors.black38)));
    
    final recent = sessions.take(3).toList();
    return Column(
      children: recent.map((s) {
        final subject = subjects.firstWhere((sub) => sub.id == s.subjectId, orElse: () => subjects.first);
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.05))),
          child: Row(
            children: [
              Container(width: 4, height: 40, decoration: BoxDecoration(color: Color(subject.colorValue), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                    Text('${s.durationMinutes} min • ${DateFormat('MMM dd, hh:mm a').format(s.startTime)}', style: const TextStyle(color: Colors.black45, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black26),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textColor)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
      child: Center(child: Text(message, style: const TextStyle(color: Colors.black38))),
    );
  }
}
