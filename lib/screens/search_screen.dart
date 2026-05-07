import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../models/topic.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSubjectId;
  TopicStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    final filteredTopics = topics.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesSubject = _selectedSubjectId == null || t.subjectId == _selectedSubjectId;
      final matchesStatus = _selectedStatus == null || t.status == _selectedStatus;
      return matchesSearch && matchesSubject && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Topic Finder'), elevation: 0, backgroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search for Algebra, Flutter, etc...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() { _searchController.clear(); }))
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilters(subjects),
              ],
            ),
          ),
          if (_searchController.text.isEmpty && _selectedSubjectId == null && _selectedStatus == null)
            _buildSearchShortcuts()
          else
            Expanded(
              child: filteredTopics.isEmpty
                  ? _buildEmptySearch()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      itemCount: filteredTopics.length,
                      itemBuilder: (context, index) {
                        final topic = filteredTopics[index];
                        final subject = subjects.firstWhere(
                          (s) => s.id == topic.subjectId,
                          orElse: () => Subject(id: '', name: 'Unknown', colorValue: Colors.grey.value, createdAt: DateTime.now()),
                        );
                        return _SearchResultTile(topic: topic, subject: subject);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchShortcuts() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Quick Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(label: 'Not Started', icon: Icons.radio_button_unchecked, color: Colors.black26, onTap: () => setState(() => _selectedStatus = TopicStatus.notStarted)),
              _FilterChip(label: 'Learning', icon: Icons.psychology_rounded, color: AppTheme.primaryColor, onTap: () => setState(() => _selectedStatus = TopicStatus.inProgress)),
              _FilterChip(label: 'Completed', icon: Icons.check_circle_rounded, color: const Color(0xFF10B981), onTap: () => setState(() => _selectedStatus = TopicStatus.completed)),
            ],
          ),
          const SizedBox(height: 40),
          const Text('Search Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _SearchTipItem(icon: Icons.filter_list_rounded, title: 'Use Filters', desc: 'Narrow down topics by subject or current progress status.'),
          _SearchTipItem(icon: Icons.history_rounded, title: 'Subject History', desc: 'Find topics from specific curriculums using the subject dropdown.'),
          _SearchTipItem(icon: Icons.bolt_rounded, title: 'Quick Mastery', desc: 'Search for "Completed" topics to review what you have already learned.'),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('We couldn\'t find any matching topics', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
          const Text('Try adjusting your search or filters', style: TextStyle(color: Colors.black12, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFilters(List<Subject> subjects) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: _selectedSubjectId,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true, fillColor: AppTheme.backgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            hint: const Text('All Subjects', style: TextStyle(fontSize: 12)),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Subjects')),
              ...subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
            ],
            onChanged: (val) => setState(() => _selectedSubjectId = val),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<TopicStatus?>(
            value: _selectedStatus,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true, fillColor: AppTheme.backgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            hint: const Text('Status', style: TextStyle(fontSize: 12)),
            items: const [
              DropdownMenuItem(value: null, child: Text('Any Status')),
              DropdownMenuItem(value: TopicStatus.notStarted, child: Text('Not Started')),
              DropdownMenuItem(value: TopicStatus.inProgress, child: Text('In Progress')),
              DropdownMenuItem(value: TopicStatus.completed, child: Text('Completed')),
            ],
            onChanged: (val) => setState(() => _selectedStatus = val),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _SearchTipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _SearchTipItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor.withOpacity(0.4), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Colors.black38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Topic topic;
  final Subject subject;
  const _SearchResultTile({required this.topic, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.03))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: Color(subject.colorValue), shape: BoxShape.circle)),
        title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor, fontSize: 15)),
        subtitle: Text(subject.name, style: TextStyle(color: Color(subject.colorValue), fontSize: 11, fontWeight: FontWeight.w700)),
        trailing: _StatusBadge(status: topic.status),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TopicStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case TopicStatus.notStarted: color = Colors.black26; label = 'Pending'; break;
      case TopicStatus.inProgress: color = AppTheme.primaryColor; label = 'Learning'; break;
      case TopicStatus.completed: color = const Color(0xFF10B981); label = 'Done'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
