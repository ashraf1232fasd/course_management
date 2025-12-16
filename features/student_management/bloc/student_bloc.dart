import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/student.dart';

// Events
abstract class StudentEvent extends Equatable {
  const StudentEvent();
  @override
  List<Object> get props => [];
}

class LoadStudents extends StudentEvent {
  final String groupId;
  const LoadStudents(this.groupId);
  @override
  List<Object> get props => [groupId];
}

class AddStudent extends StudentEvent {
  final Student student;
  const AddStudent(this.student);
  @override
  List<Object> get props => [student];
}

class UpdateStudent extends StudentEvent {
  final Student student;
  const UpdateStudent(this.student);
  @override
  List<Object> get props => [student];
}

class DeleteStudent extends StudentEvent {
  final String studentId;
  const DeleteStudent(this.studentId);
  @override
  List<Object> get props => [studentId];
}

class MarkVideoAsWatched extends StudentEvent {
  final String studentId;
  final String videoId;
  const MarkVideoAsWatched({required this.studentId, required this.videoId});
  @override
  List<Object> get props => [studentId, videoId];
}

// State
class StudentState extends Equatable {
  final List<Student> students;
  final String? currentGroupId;
  
  const StudentState({this.students = const [], this.currentGroupId});

  List<Student> get currentGroupStudents => currentGroupId == null 
      ? [] 
      : students.where((s) => s.groupId == currentGroupId).toList();
  
  @override
  List<Object?> get props => [students, currentGroupId];

  Map<String, dynamic> toJson() {
    return {
      'students': students.map((s) => s.toJson()).toList(),
      'currentGroupId': currentGroupId,
    };
  }

  factory StudentState.fromJson(Map<String, dynamic> json) {
    return StudentState(
      students: (json['students'] as List)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentGroupId: json['currentGroupId'] as String?,
    );
  }
}

// BLoC
class StudentBloc extends HydratedBloc<StudentEvent, StudentState> {
  StudentBloc() : super(const StudentState()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<MarkVideoAsWatched>(_onMarkVideoAsWatched);
  }

  void _onLoadStudents(LoadStudents event, Emitter<StudentState> emit) {
    emit(StudentState(students: state.students, currentGroupId: event.groupId));
  }

  void _onAddStudent(AddStudent event, Emitter<StudentState> emit) {
    final updatedStudents = List<Student>.from(state.students)..add(event.student);
    emit(StudentState(students: updatedStudents, currentGroupId: state.currentGroupId));
  }

  void _onUpdateStudent(UpdateStudent event, Emitter<StudentState> emit) {
    final updatedStudents = state.students.map((s) {
      return s.id == event.student.id ? event.student : s;
    }).toList();
    emit(StudentState(students: updatedStudents, currentGroupId: state.currentGroupId));
  }

  void _onDeleteStudent(DeleteStudent event, Emitter<StudentState> emit) {
    final updatedStudents = state.students.where((s) => s.id != event.studentId).toList();
    emit(StudentState(students: updatedStudents, currentGroupId: state.currentGroupId));
  }

  void _onMarkVideoAsWatched(MarkVideoAsWatched event, Emitter<StudentState> emit) {
    final updatedStudents = state.students.map((s) {
      if (s.id == event.studentId) {
        if (!s.watchedVideoIds.contains(event.videoId)) {
          final updatedWatchedIds = List<String>.from(s.watchedVideoIds)..add(event.videoId);
          return s.copyWith(watchedVideoIds: updatedWatchedIds);
        } 
      }
      return s;
    }).toList();
    emit(StudentState(students: updatedStudents, currentGroupId: state.currentGroupId));
  }

  @override
  StudentState? fromJson(Map<String, dynamic> json) => StudentState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(StudentState state) => state.toJson();
}
