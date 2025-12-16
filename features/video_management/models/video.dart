import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String groupId;
  final String title;
  final bool isEnabled;
  final int timerDurationSeconds;
  final DateTime? timerEndTime;
  final String? filePath;
  final List<String> assignedStudentIds;
  final bool isForAllStudents;

  const Video({
    required this.id,
    required this.groupId,
    required this.title,
    this.isEnabled = false,
    this.timerDurationSeconds = 0,
    this.timerEndTime,
    this.filePath,
    this.assignedStudentIds = const [],
    this.isForAllStudents = true,
  });

  Video copyWith({
    String? id,
    String? groupId,
    String? title,
    bool? isEnabled,
    int? timerDurationSeconds,
    DateTime? timerEndTime,
    String? filePath,
    List<String>? assignedStudentIds,
    bool? isForAllStudents,
  }) {
    return Video(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      isEnabled: isEnabled ?? this.isEnabled,
      timerDurationSeconds: timerDurationSeconds ?? this.timerDurationSeconds,
      timerEndTime: timerEndTime ?? this.timerEndTime,
      filePath: filePath ?? this.filePath,
      assignedStudentIds: assignedStudentIds ?? this.assignedStudentIds,
      isForAllStudents: isForAllStudents ?? this.isForAllStudents,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        title,
        isEnabled,
        timerDurationSeconds,
        timerEndTime,
        filePath,
        assignedStudentIds,
        isForAllStudents,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'isEnabled': isEnabled,
      'timerDurationSeconds': timerDurationSeconds,
      'timerEndTime': timerEndTime?.toIso8601String(),
      'filePath': filePath,
      'assignedStudentIds': assignedStudentIds,
      'isForAllStudents': isForAllStudents,
    };
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      isEnabled: json['isEnabled'] as bool,
      timerDurationSeconds: json['timerDurationSeconds'] as int,
      timerEndTime: json['timerEndTime'] != null
          ? DateTime.parse(json['timerEndTime'] as String)
          : null,
      filePath: json['filePath'] as String?,
      assignedStudentIds:
          List<String>.from(json['assignedStudentIds'] as List? ?? []),
      isForAllStudents: json['isForAllStudents'] as bool? ?? true,
    );
  }
}
