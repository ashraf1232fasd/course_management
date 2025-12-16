import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../attendance/bloc/attendance_bloc.dart';

import '../bloc/student_bloc.dart';
import '../models/student.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late TextEditingController _notesController;
  late TextEditingController _gradeController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.student.notes);
    _gradeController = TextEditingController(text: widget.student.grade);
    // Ensure attendance is loaded for this group
    context.read<AttendanceBloc>().add(LoadAttendance(widget.student.groupId));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedStudent = widget.student.copyWith(
      notes: _notesController.text,
      grade: _gradeController.text,
    );
    context.read<StudentBloc>().add(UpdateStudent(updatedStudent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildPerformanceSection(),
            const SizedBox(height: 24),
            _buildAttendanceHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.lightBlue.withValues(alpha: 0.2),
            child: Text(
              widget.student.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.student.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'Enrolled: ${widget.student.enrollmentDate.toString().split(' ')[0]}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance & Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _gradeController,
            decoration: const InputDecoration(
              labelText: 'Grade / Level',
              prefixIcon: Icon(Icons.grade),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Teacher Notes',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final groupAttendance = state.currentGroupAttendance;
        // Sort by date descending
        groupAttendance.sort((a, b) => b.date.compareTo(a.date));

        final totalClasses = groupAttendance.length;
        final presentClasses = groupAttendance
            .where((a) => a.presentStudentIds.contains(widget.student.id))
            .length;
        final attendanceRate = totalClasses == 0 ? 0 : (presentClasses / totalClasses * 100).round();

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: attendanceRate >= 75
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$attendanceRate%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: attendanceRate >= 75 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (groupAttendance.isEmpty)
                const Text('No attendance records found.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupAttendance.length > 5 ? 5 : groupAttendance.length,
                  itemBuilder: (context, index) {
                    final record = groupAttendance[index];
                    final isPresent = record.presentStudentIds.contains(widget.student.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isPresent ? Icons.check_circle : Icons.cancel,
                        color: isPresent ? Colors.green : Colors.red,
                      ),
                      title: Text(record.date.toString().split(' ')[0]),
                      trailing: Text(
                        isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: isPresent ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
