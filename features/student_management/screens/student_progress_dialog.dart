import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../course_management/models/group.dart';
import '../models/student.dart';
import '../../video_management/bloc/video_bloc.dart';

class StudentProgressDialog extends StatelessWidget {
  final Student student;
  final CourseGroup group;

  const StudentProgressDialog({
    super.key,
    required this.student,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure videos are loaded
    context.read<VideoBloc>().add(LoadVideos(group.id));

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.lightBlue.withValues(alpha: 0.1),
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Video Progress',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<VideoBloc, VideoState>(
              builder: (context, state) {
                final videos = state.videos.where((v) => v.groupId == group.id).toList();
                
                // Filter videos relevant to this student (assigned or for all)
                final assignedVideos = videos.where((v) {
                  if (v.isForAllStudents) return true;
                  return v.assignedStudentIds.contains(student.id);
                }).toList();

                if (assignedVideos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No videos assigned to this student.'),
                    ),
                  );
                }

                final watchedCount = assignedVideos.where((v) => student.watchedVideoIds.contains(v.id)).length;
                final progress = assignedVideos.isEmpty ? 0.0 : watchedCount / assignedVideos.length;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}% Completed',
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: assignedVideos.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final video = assignedVideos[index];
                          final isWatched = student.watchedVideoIds.contains(video.id);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isWatched ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isWatched ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              video.title,
                              style: TextStyle(
                                decoration: isWatched ? TextDecoration.lineThrough : null,
                                color: isWatched ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
