import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../course_management/models/group.dart';
import '../../student_management/models/student.dart';
import '../../student_management/bloc/student_bloc.dart';
import '../../video_management/bloc/video_bloc.dart';
import '../../attendance/bloc/attendance_bloc.dart';
import '../../video_management/screens/video_player_screen.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final CourseGroup group;
  final Student student;

  const StudentCourseDetailScreen({
    super.key,
    required this.group,
    required this.student,
  });

  @override
  State<StudentCourseDetailScreen> createState() => _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Ensure videos are loaded for this group
    context.read<VideoBloc>().add(LoadVideos(widget.group.id));
    // Ensure attendance is loaded for this group
    context.read<AttendanceBloc>().add(LoadAttendance(widget.group.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.group.name),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Videos', icon: Icon(Icons.play_circle_outline)),
            Tab(text: 'Attendance', icon: Icon(Icons.calendar_today_outlined)),
            Tab(text: 'Evaluation', icon: Icon(Icons.grade_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VideosTab(group: widget.group, student: widget.student),
          _AttendanceTab(student: widget.student, group: widget.group),
          _EvaluationTab(student: widget.student),
        ],
      ),
    );
  }
}

class _VideosTab extends StatefulWidget {
  final CourseGroup group;
  final Student student;

  const _VideosTab({required this.group, required this.student});

  @override
  State<_VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<_VideosTab> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update UI every second for countdowns
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, videoState) {
        // Filter videos for this group and this student
        final groupVideos = videoState.videos.where((v) => v.groupId == widget.group.id).toList();
        
        final assignedVideos = groupVideos.where((v) {
          // Check visibility toggle
          if (!v.isEnabled) return false;

          // If video is for all students, show it
          if (v.isForAllStudents) return true;
          // Otherwise check if student is assigned
          return v.assignedStudentIds.contains(widget.student.id);
        }).toList();

        if (assignedVideos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No videos assigned to you yet.',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<StudentBloc, StudentState>(
          builder: (context, studentState) {
            // Get the latest student record to check watched status
            final currentStudent = studentState.students.firstWhere((s) => s.id == widget.student.id, orElse: () => widget.student);

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: assignedVideos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final video = assignedVideos[index];
                final isWatched = currentStudent.watchedVideoIds.contains(video.id);
                
                // Check expiration
                final now = DateTime.now();
                final isExpired = video.timerEndTime != null && now.isAfter(video.timerEndTime!);
                final timeLeft = video.timerEndTime != null && !isExpired 
                    ? video.timerEndTime!.difference(now) 
                    : null;

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isExpired 
                            ? Colors.grey.withValues(alpha: 0.1)
                            : isWatched 
                                ? Colors.green.withValues(alpha: 0.1) 
                                : AppTheme.lightBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpired 
                            ? Icons.timer_off_outlined
                            : isWatched 
                                ? Icons.check 
                                : Icons.play_arrow,
                        color: isExpired 
                            ? Colors.grey 
                            : isWatched 
                                ? Colors.green 
                                : AppTheme.darkBlue,
                      ),
                    ),
                    title: Text(
                      video.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                        decoration: isExpired ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isExpired)
                          const Text(
                            'Expired',
                            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        else if (timeLeft != null)
                          Text(
                            'Expires in: ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m ${timeLeft.inSeconds % 60}s',
                            style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            isWatched ? 'Watched' : 'Tap to watch',
                            style: TextStyle(
                              color: isWatched ? Colors.green : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    onTap: isExpired ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This video has expired and cannot be viewed.')),
                      );
                    } : () {
                      if (video.filePath == null || video.filePath!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Video file is not available.')),
                        );
                        return;
                      }
                      // Navigate to video player
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                            filePath: video.filePath!,
                            title: video.title,
                            onVideoFinished: () {
                              // Mark as watched when finished
                              context.read<StudentBloc>().add(
                                MarkVideoAsWatched(studentId: widget.student.id, videoId: video.id),
                              );
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Video completed! Marked as watched.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final Student student;
  final CourseGroup group;

  const _AttendanceTab({required this.student, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final groupAttendance = state.attendanceRecords.where((a) => a.groupId == group.id).toList();
        
        // Sort by date descending
        groupAttendance.sort((a, b) => b.date.compareTo(a.date));

        if (groupAttendance.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No attendance records found.',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        final totalClasses = groupAttendance.length;
        final presentClasses = groupAttendance
            .where((a) => a.presentStudentIds.contains(student.id))
            .length;
        final attendanceRate = totalClasses == 0 ? 0 : (presentClasses / totalClasses * 100).round();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attendance Rate',
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
                ),
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupAttendance.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final record = groupAttendance[index];
                  final isPresent = record.presentStudentIds.contains(student.id);
                  return CustomCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPresent ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPresent ? Icons.check : Icons.close,
                          color: isPresent ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        record.date.toString().split(' ')[0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: isPresent ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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

class _EvaluationTab extends StatelessWidget {
  final Student student;

  const _EvaluationTab({required this.student});

  @override
  Widget build(BuildContext context) {
    // Listen to StudentBloc to update grades/notes in real-time if they change
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        final currentStudent = state.students.firstWhere((s) => s.id == student.id, orElse: () => student);
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                context,
                'Current Grade',
                currentStudent.grade.isNotEmpty ? currentStudent.grade : 'Not Graded',
                Icons.score,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Instructor Notes',
                currentStudent.notes.isNotEmpty ? currentStudent.notes : 'No notes available.',
                Icons.note,
                Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
