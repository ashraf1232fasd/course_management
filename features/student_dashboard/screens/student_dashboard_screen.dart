import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../course_management/bloc/group_bloc.dart';
import '../../course_management/models/group.dart';
import '../../student_management/bloc/student_bloc.dart';
import '../../student_management/models/student.dart';
import 'student_course_detail_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  final String email;

  const StudentDashboardScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    // Find all student records with this email
    final allStudents = context.read<StudentBloc>().state.students;
    final myStudentRecords = allStudents.where((s) => s.email == email).toList();
    
    // Get unique group IDs
    final myGroupIds = myStudentRecords.map((s) => s.groupId).toSet();
    
    // Filter groups
    final allGroups = context.read<GroupBloc>().state.groups;
    final myGroups = allGroups.where((g) => myGroupIds.contains(g.id)).toList();

    // Get student name from the first record found (assuming same name across groups)
    final studentName = myStudentRecords.isNotEmpty ? myStudentRecords.first.name : 'Student';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              studentName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ).animate().fadeIn().slideX(),
            
            const SizedBox(height: 32),
            
            if (myGroups.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.class_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'You are not enrolled in any courses yet.',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.5,
                ),
                itemCount: myGroups.length,
                itemBuilder: (context, index) {
                  final group = myGroups[index];
                  // Find the specific student record for this group to pass along
                  final studentRecord = myStudentRecords.firstWhere((s) => s.groupId == group.id);
                  
                  return _StudentCourseCard(
                    group: group,
                    student: studentRecord,
                    index: index,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentCourseCard extends StatelessWidget {
  final CourseGroup group;
  final Student student;
  final int index;

  const _StudentCourseCard({
    required this.group,
    required this.student,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: Theme.of(context).cardColor,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentCourseDetailScreen(
              group: group,
              student: student,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              group.name,
              style: const TextStyle(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            group.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.play_circle_outline, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 4),
              const Text('Videos', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.assignment_turned_in_outlined, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 4),
              const Text('Attendance', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2);
  }
}
