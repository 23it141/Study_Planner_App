import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  Subject copyWith({
    String? name,
    int? colorValue,
  }) {
    return Subject(
      id: this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: this.createdAt,
    );
  }
}
