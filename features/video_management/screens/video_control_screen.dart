import 'video_player_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../course_management/models/group.dart';
import '../../student_management/bloc/student_bloc.dart';
import '../bloc/video_bloc.dart';
import '../models/video.dart';

class VideoControlScreen extends StatefulWidget {
  final CourseGroup group;

  const VideoControlScreen({super.key, required this.group});

  @override
  State<VideoControlScreen> createState() => _VideoControlScreenState();
}

class _VideoControlScreenState extends State<VideoControlScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VideoBloc>().add(LoadVideos(widget.group.id));
    context.read<StudentBloc>().add(LoadStudents(widget.group.id));
  }

  void _showAddVideoSheet() {
    final videoBloc = context.read<VideoBloc>();
    final studentBloc = context.read<StudentBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: videoBloc),
          BlocProvider.value(value: studentBloc),
        ],
        child: _AddVideoSheet(group: widget.group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.group.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVideoSheet,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.surface,
        icon: const Icon(Icons.add),
        label: const Text('Add Video'),
      ),
      body: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          final videos = state.currentGroupVideos;
          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No videos yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: videos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final video = videos[index];
              return _VideoCard(video: video);
            },
          );
        },
      ),
    );
  }
}

class _AddVideoSheet extends StatefulWidget {
  final CourseGroup group;

  const _AddVideoSheet({required this.group});

  @override
  State<_AddVideoSheet> createState() => _AddVideoSheetState();
}

class _AddVideoSheetState extends State<_AddVideoSheet> {
  final _titleController = TextEditingController();
  String? _selectedFilePath;
  bool _isForAllStudents = true;
  final Set<String> _selectedStudentIds = {};

  final _daysController = TextEditingController(text: '0');
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '0');

  Future<void> _pickFile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening file picker...'),
        duration: Duration(milliseconds: 500),
      ),
    );
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null) {
        if (!mounted) return;
        setState(() {
          _selectedFilePath = result.files.single.path;
          if (_titleController.text.isEmpty) {
            _titleController.text = result.files.single.name;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
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
            Text(              'Add New Video',              style: TextStyle(                fontSize: 24,                fontWeight: FontWeight.bold,                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a video and assign it to students.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
            ),
            const SizedBox(height: 32),

            // 1. File Selection
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedFilePath != null
                          ? AppTheme.black
                          : Theme.of(context).colorScheme.outline,
                      width: _selectedFilePath != null ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.folder_open, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFilePath != null
                                  ? 'Selected File'
                                  : 'Select Video File',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedFilePath != null
                                  ? _selectedFilePath!.split('\\').last
                                  : 'Tap to browse...',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (_selectedFilePath != null)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Title
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(labelText: 'Video Title',labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  prefixIcon: Icon(Icons.title, color: Theme.of(context).colorScheme.secondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. Assignment
            const Text(
              'Assignment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Assign to All Students',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _isForAllStudents,
                    activeThumbColor: Theme.of(context).colorScheme.onSurface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    onChanged: (val) => setState(() => _isForAllStudents = val),
                  ),
                  if (!_isForAllStudents) ...[
                    const Divider(height: 1),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: BlocBuilder<StudentBloc, StudentState>(
                        builder: (context, state) {
                          final students = state.currentGroupStudents;
                          if (students.isEmpty) {
                            return const Center(
                              child: Text('No students available'),
                            );
                          }
                          return ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              final isSelected = _selectedStudentIds.contains(
                                student.id,
                              );
                              return CheckboxListTile(
                                title: Text(student.name),
                                value: isSelected,
                                activeColor: Theme.of(context).colorScheme.onSurface,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedStudentIds.add(student.id);
                                    } else {
                                      _selectedStudentIds.remove(student.id);
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Timer
            const Text(
              'Default Timer Duration',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTimeInput(_daysController, 'Days')),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeInput(_hoursController, 'Hours')),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeInput(_minutesController, 'Mins')),
              ],
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    try {
                      final days = int.tryParse(_daysController.text) ?? 0;
                      final hours = int.tryParse(_hoursController.text) ?? 0;
                      final mins = int.tryParse(_minutesController.text) ?? 0;
                      final totalSeconds =
                          (days * 86400) + (hours * 3600) + (mins * 60);

                      final newVideo = Video(
                        id: const Uuid().v4(),
                        groupId: widget.group.id,
                        title: _titleController.text,
                        filePath: _selectedFilePath,
                        isForAllStudents: _isForAllStudents,
                        assignedStudentIds: _isForAllStudents
                            ? []
                            : _selectedStudentIds.toList(),
                        timerDurationSeconds: totalSeconds,
                      );
                      context.read<VideoBloc>().add(AddVideo(newVideo));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Video added successfully'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding video: ')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a video title'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Add Video',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final Video video;

  const _VideoCard({required this.video});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  late Timer _timer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (widget.video.timerEndTime != null) {
      final remaining = widget.video.timerEndTime!.difference(DateTime.now());
      if (remaining.isNegative) {
        setState(() => _remainingTime = 'Expired');
      } else {
        final days = remaining.inDays;
        final hours = remaining.inHours % 24;
        final mins = remaining.inMinutes % 60;
        final secs = remaining.inSeconds % 60;

        if (days > 0) {
          setState(() => _remainingTime = '${days}d ${hours}h ${mins}m');
        } else if (hours > 0) {
          setState(() => _remainingTime = '${hours}h ${mins}m ${secs}s');
        } else {
          setState(() => _remainingTime = '${mins}m ${secs}s');
        }
      }
    } else {
      setState(() => _remainingTime = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.video.isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      if (widget.video.filePath != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(
                              filePath: widget.video.filePath!,
                              title: widget.video.title,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No video file associated'),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title,
                        style: TextStyle(
                          color: widget.video.isEnabled
                              ? Colors.white
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.video.filePath != null)
                        Text(
                          widget.video.filePath!.split('\\').last,
                          style: TextStyle(
                            color: widget.video.isEnabled
                                ? Colors.white70
                                : Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.video.isEnabled,
                  onChanged: (val) {
                    context.read<VideoBloc>().add(
                      ToggleVideo(widget.video.id, val),
                    );
                  },
                  activeThumbColor: Color(0xFF00E5FF),
                  activeTrackColor: Colors.white.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.video.isForAllStudents
                          ? 'Assigned to: All Students'
                          : 'Assigned to: ${widget.video.assignedStudentIds.length} Students',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.video.isEnabled)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.video.timerEndTime == null
                                ? Colors.grey[100]
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer,
                                color: widget.video.timerEndTime == null
                                    ? Colors.grey
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.video.timerEndTime == null
                                    ? _formatDuration(
                                        widget.video.timerDurationSeconds,
                                      )
                                    : _remainingTime,
                                style: TextStyle(
                                  color: widget.video.timerEndTime == null
                                      ? Colors.grey[800]
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.video.timerEndTime == null)
                        FloatingActionButton.small(
                          heroTag: 'start_${widget.video.id}',
                          onPressed: widget.video.timerDurationSeconds > 0
                              ? () {
                                  context.read<VideoBloc>().add(
                                    StartTimer(widget.video.id),
                                  );
                                }
                              : null,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.play_arrow,color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      else
                        FloatingActionButton.small(
                          heroTag: 'stop_${widget.video.id}',
                          onPressed: () {
                            context.read<VideoBloc>().add(
                              StopTimer(widget.video.id),
                            );
                          },
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.stop, color: Colors.white),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: TextButton.icon(
                onPressed: () {
                  context.read<VideoBloc>().add(DeleteVideo(widget.video.id));
                },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.grey,
                ),
                label: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return 'No Timer';
    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;

    List<String> parts = [];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (mins > 0) parts.add('${mins}m');

    return parts.join(' ');
  }
}















