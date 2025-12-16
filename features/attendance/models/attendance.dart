import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final String id;
  final String groupId;
  final DateTime date;
  final List<String> presentStudentIds;

  const Attendance({
    required this.id,
    required this.groupId,
    required this.date,
    required this.presentStudentIds,
  });

  Attendance copyWith({
    String? id,
    String? groupId,
    DateTime? date,
    List<String>? presentStudentIds,
  }) {
    return Attendance(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      presentStudentIds: presentStudentIds ?? this.presentStudentIds,
    );
  }

  @override
  List<Object?> get props => [id, groupId, date, presentStudentIds];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'date': date.toIso8601String(),
      'presentStudentIds': presentStudentIds,
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      date: DateTime.parse(json['date'] as String),
      presentStudentIds: List<String>.from(json['presentStudentIds'] as List),
    );
  }
}
