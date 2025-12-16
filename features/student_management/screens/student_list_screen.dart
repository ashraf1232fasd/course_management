import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../course_management/models/group.dart';
import '../bloc/student_bloc.dart';
import '../models/student.dart';
import 'student_detail_screen.dart';
import 'student_progress_dialog.dart';

class StudentListScreen extends StatefulWidget {
  final CourseGroup group;

  const StudentListScreen({super.key, required this.group});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadStudents(widget.group.id));
  }

  void _showStudentSheet([Student? student]) {
    final nameController = TextEditingController(text: student?.name ?? '');
    final emailController = TextEditingController(text: student?.email ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 32,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              student == null ? 'Add New Student' : 'Edit Student',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              student == null ? 'Enter the student\'s details below.' : 'Update the student\'s information.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: TextField(
                controller: nameController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.darkBlue),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: TextField(
                controller: emailController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.darkBlue),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                    if (student == null) {
                      final newStudent = Student(
                        id: const Uuid().v4(),
                        groupId: widget.group.id,
                        name: nameController.text,
                        email: emailController.text,
                        enrollmentDate: DateTime.now(),
                      );
                      context.read<StudentBloc>().add(AddStudent(newStudent));
                    } else {
                      final updatedStudent = student.copyWith(
                        name: nameController.text,
                        email: emailController.text,
                      );
                      context.read<StudentBloc>().add(UpdateStudent(updatedStudent));
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  student == null ? 'Add Student' : 'Save Changes',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentSheet(),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        foregroundColor: Theme.of(context).colorScheme.surface,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          final students = state.currentGroupStudents;
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No students enrolled',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final student = students[index];
              return CustomCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentDetailScreen(student: student),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Hero(
                    tag: 'avatar_${student.id}',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.lightBlue.withValues(alpha: 0.1),
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (student.email.isNotEmpty)
                        Text(student.email, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      Text(
                        'Enrolled: ${student.enrollmentDate.toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'View Progress',
                        icon: const Icon(Icons.bar_chart, color: AppTheme.darkBlue),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => StudentProgressDialog(student: student, group: widget.group),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        onPressed: () => _showStudentSheet(student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () {
                          context.read<StudentBloc>().add(DeleteStudent(student.id));
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX();
            },
          );
        },
      ),
    );
  }
}
