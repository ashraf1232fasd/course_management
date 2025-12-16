import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String groupId;
  final String name;
  final String email;
  final DateTime enrollmentDate;
  final String notes;
  final String grade;
  final List<String> watchedVideoIds;

  const Student({
    required this.id,
    required this.groupId,
    required this.name,
    this.email = '',
    required this.enrollmentDate,
    this.notes = '',
    this.grade = '',
    this.watchedVideoIds = const [],
  });

  Student copyWith({
    String? id,
    String? groupId,
    String? name,
    String? email,
    DateTime? enrollmentDate,
    String? notes,
    String? grade,
    List<String>? watchedVideoIds,
  }) {
    return Student(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      email: email ?? this.email,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      notes: notes ?? this.notes,
      grade: grade ?? this.grade,
      watchedVideoIds: watchedVideoIds ?? this.watchedVideoIds,
    );
  }

  @override
  List<Object?> get props => [id, groupId, name, email, enrollmentDate, notes, grade, watchedVideoIds];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'email': email,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'notes': notes,
      'grade': grade,
      'watchedVideoIds': watchedVideoIds,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      notes: json['notes'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      watchedVideoIds: (json['watchedVideoIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}