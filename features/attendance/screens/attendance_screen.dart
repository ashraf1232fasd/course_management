import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../course_management/models/group.dart';
import '../../student_management/bloc/student_bloc.dart';
import '../bloc/attendance_bloc.dart';
import '../models/attendance.dart';

class AttendanceScreen extends StatefulWidget {
  final CourseGroup group;

  const AttendanceScreen({super.key, required this.group});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(LoadAttendance(widget.group.id));
    context.read<StudentBloc>().add(LoadStudents(widget.group.id));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.black,
              onPrimary: AppTheme.white,
              onSurface: AppTheme.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Attendance: ${widget.group.name}')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            child: CustomCard(
              onTap: () => _selectDate(context),
              padding: const EdgeInsets.all(16),
              color: AppTheme.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Date',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDate.toString().split(' ')[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.calendar_today, color: Colors.white),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.2),
          Expanded(
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, studentState) {
                final students = studentState.currentGroupStudents;
                if (students.isEmpty) {
                  return const Center(
                    child: Text('No students in this group.'),
                  );
                }

                return BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, attendanceState) {
                    final attendance = attendanceState.getAttendanceForDate(
                      _selectedDate,
                    );
                    final presentIds = attendance?.presentStudentIds ?? [];

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: students.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final isPresent = presentIds.contains(student.id);

                        return CustomCard(
                          padding: EdgeInsets.zero,
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            secondary: CircleAvatar(
                              backgroundColor: isPresent
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              child: Icon(
                                isPresent ? Icons.check : Icons.person,
                                color: isPresent ? Colors.green : Colors.grey,
                              ),
                            ),
                            value: isPresent,
                            activeColor: Colors.green,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (bool? value) {
                              final newPresentIds = List<String>.from(
                                presentIds,
                              );
                              if (value == true) {
                                newPresentIds.add(student.id);
                              } else {
                                newPresentIds.remove(student.id);
                              }

                              final newAttendance = Attendance(
                                id: attendance?.id ?? const Uuid().v4(),
                                groupId: widget.group.id,
                                date: _selectedDate,
                                presentStudentIds: newPresentIds,
                              );

                              context.read<AttendanceBloc>().add(
                                SaveAttendance(newAttendance),
                              );
                            },
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms).slideX();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
