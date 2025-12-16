import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/attendance.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object> get props => [];
}

class LoadAttendance extends AttendanceEvent {
  final String groupId;
  const LoadAttendance(this.groupId);
  @override
  List<Object> get props => [groupId];
}

class SaveAttendance extends AttendanceEvent {
  final Attendance attendance;
  const SaveAttendance(this.attendance);
  @override
  List<Object> get props => [attendance];
}

// State
class AttendanceState extends Equatable {
  final List<Attendance> attendanceRecords;
  final String? currentGroupId;
  
  const AttendanceState({this.attendanceRecords = const [], this.currentGroupId});

  List<Attendance> get currentGroupAttendance => currentGroupId == null 
      ? [] 
      : attendanceRecords.where((a) => a.groupId == currentGroupId).toList();

  Attendance? getAttendanceForDate(DateTime date) {
    try {
      return currentGroupAttendance.firstWhere(
        (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }
  
  @override
  List<Object?> get props => [attendanceRecords, currentGroupId];

  Map<String, dynamic> toJson() {
    return {
      'attendanceRecords': attendanceRecords.map((a) => a.toJson()).toList(),
      'currentGroupId': currentGroupId,
    };
  }

  factory AttendanceState.fromJson(Map<String, dynamic> json) {
    return AttendanceState(
      attendanceRecords: (json['attendanceRecords'] as List)
          .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentGroupId: json['currentGroupId'] as String?,
    );
  }
}

// BLoC
class AttendanceBloc extends HydratedBloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(const AttendanceState()) {
    on<LoadAttendance>(_onLoadAttendance);
    on<SaveAttendance>(_onSaveAttendance);
  }

  void _onLoadAttendance(LoadAttendance event, Emitter<AttendanceState> emit) {
    emit(AttendanceState(attendanceRecords: state.attendanceRecords, currentGroupId: event.groupId));
  }

  void _onSaveAttendance(SaveAttendance event, Emitter<AttendanceState> emit) {
    // Remove existing record for the same date if any
    final filteredRecords = state.attendanceRecords.where((a) {
      if (a.groupId != event.attendance.groupId) return true;
      final isSameDate = a.date.year == event.attendance.date.year && 
                         a.date.month == event.attendance.date.month && 
                         a.date.day == event.attendance.date.day;
      return !isSameDate;
    }).toList();

    final updatedRecords = List<Attendance>.from(filteredRecords)..add(event.attendance);
    emit(AttendanceState(attendanceRecords: updatedRecords, currentGroupId: state.currentGroupId));
  }

  @override
  AttendanceState? fromJson(Map<String, dynamic> json) => AttendanceState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(AttendanceState state) => state.toJson();
}
