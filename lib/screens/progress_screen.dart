import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../models/topic.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Analytics'), elevation: 0, backgroundColor: Colors.transparent),
      body: subjects.isEmpty
          ? const Center(child: Text('Add subjects to visualize your progress', style: TextStyle(color: Colors.black38)))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _buildPreparationScore(topics),
                const SizedBox(height: 32),
                const Text('Completion by Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 8),
                const Text('Comparing syllabus coverage across curriculums', style: TextStyle(color: Colors.black38, fontSize: 12)),
                const SizedBox(height: 16),
                _buildBarChart(subjects, topics),
                const SizedBox(height: 32),
                const Text('Topic Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 16),
                _buildStatusDistribution(topics),
                const SizedBox(height: 32),
                const Text('Subject Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 16),
                ...subjects.map((s) => _SubjectProgressTile(subject: s, topics: topics.where((t) => t.subjectId == s.id).toList())),
                const SizedBox(height: 100),
              ],
            ),
    );
  }

  Widget _buildPreparationScore(List<Topic> topics) {
    final completed = topics.where((t) => t.status == TopicStatus.completed).length;
    final total = topics.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(
        children: [
          const Text('Readiness Score', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 16),
              const SizedBox(width: 8),
              Text('$completed finished', style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 16),
              const Icon(Icons.radio_button_unchecked_rounded, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text('${total - completed} pending', style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(List<Topic> topics) {
    final notStarted = topics.where((t) => t.status == TopicStatus.notStarted).length;
    final inProgress = topics.where((t) => t.status == TopicStatus.inProgress).length;
    final completed = topics.where((t) => t.status == TopicStatus.completed).length;
    final total = topics.isEmpty ? 1 : topics.length;

    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.03))),
      child: Row(
        children: [
          _DistributionBar(label: 'Pending', count: notStarted, color: Colors.black12, total: total),
          const SizedBox(width: 8),
          _DistributionBar(label: 'Learning', count: inProgress, color: AppTheme.primaryColor, total: total),
          const SizedBox(width: 8),
          _DistributionBar(label: 'Mastered', count: completed, color: const Color(0xFF10B981), total: total),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Subject> subjects, List<Topic> topics) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withOpacity(0.03))),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= subjects.length) return const SizedBox();
                  final name = subjects[index].name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      name.length > 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.black26)),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.black.withOpacity(0.03), strokeWidth: 1)),
          barGroups: List.generate(subjects.length, (index) {
            final s = subjects[index];
            final sTopics = topics.where((t) => t.subjectId == s.id).toList();
            final completion = sTopics.isEmpty ? 0.0 : (sTopics.where((t) => t.status == TopicStatus.completed).length / sTopics.length) * 100;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: completion,
                  color: Color(s.colorValue),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: Color(s.colorValue).withOpacity(0.05)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final int total;
  const _DistributionBar({required this.label, required this.count, required this.color, required this.total});

  @override
  Widget build(BuildContext context) {
    final flex = (count / total * 100).toInt();
    if (flex == 0) return const SizedBox();
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Expanded(child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black38)),
          Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SubjectProgressTile extends StatelessWidget {
  final Subject subject;
  final List<Topic> topics;
  const _SubjectProgressTile({required this.subject, required this.topics});

  @override
  Widget build(BuildContext context) {
    final completed = topics.where((t) => t.status == TopicStatus.completed).length;
    final progress = topics.isEmpty ? 0.0 : completed / topics.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.03))),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: Color(subject.colorValue), shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textColor)),
              const Spacer(),
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: Color(subject.colorValue), fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Color(subject.colorValue).withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation(Color(subject.colorValue)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$completed of ${topics.length} topics', style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('${(topics.fold(0.0, (sum, t) => sum + t.estimatedHours)).toInt()}h effort', style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
