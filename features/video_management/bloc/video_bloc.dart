import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/video.dart';

// Events
abstract class VideoEvent extends Equatable {
  const VideoEvent();
  @override
  List<Object> get props => [];
}

class LoadVideos extends VideoEvent {
  final String groupId;
  const LoadVideos(this.groupId);
  @override
  List<Object> get props => [groupId];
}

class AddVideo extends VideoEvent {
  final Video video;
  const AddVideo(this.video);
  @override
  List<Object> get props => [video];
}

class DeleteVideo extends VideoEvent {
  final String videoId;
  const DeleteVideo(this.videoId);
  @override
  List<Object> get props => [videoId];
}

class ToggleVideo extends VideoEvent {
  final String videoId;
  final bool isEnabled;
  const ToggleVideo(this.videoId, this.isEnabled);
  @override
  List<Object> get props => [videoId, isEnabled];
}

class SetTimer extends VideoEvent {
  final String videoId;
  final int durationSeconds;
  const SetTimer(this.videoId, this.durationSeconds);
  @override
  List<Object> get props => [videoId, durationSeconds];
}

class StartTimer extends VideoEvent {
  final String videoId;
  const StartTimer(this.videoId);
  @override
  List<Object> get props => [videoId];
}

class StopTimer extends VideoEvent {
  final String videoId;
  const StopTimer(this.videoId);
  @override
  List<Object> get props => [videoId];
}

class _Tick extends VideoEvent {
  const _Tick();
}

// State
class VideoState extends Equatable {
  final List<Video> videos;
  final String? currentGroupId;

  const VideoState({this.videos = const [], this.currentGroupId});

  List<Video> get currentGroupVideos => currentGroupId == null
      ? []
      : videos.where((v) => v.groupId == currentGroupId).toList();

  @override
  List<Object?> get props => [videos, currentGroupId];

  Map<String, dynamic> toJson() {
    return {
      'videos': videos.map((v) => v.toJson()).toList(),
      'currentGroupId': currentGroupId,
    };
  }

  factory VideoState.fromJson(Map<String, dynamic> json) {
    return VideoState(
      videos: (json['videos'] as List)
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentGroupId: json['currentGroupId'] as String?,
    );
  }
}

// BLoC
class VideoBloc extends HydratedBloc<VideoEvent, VideoState> {
  Timer? _timer;

  VideoBloc() : super(const VideoState()) {
    on<LoadVideos>(_onLoadVideos);
    on<AddVideo>(_onAddVideo);
    on<DeleteVideo>(_onDeleteVideo);
    on<ToggleVideo>(_onToggleVideo);
    on<SetTimer>(_onSetTimer);
    on<StartTimer>(_onStartTimer);
    on<StopTimer>(_onStopTimer);
    on<_Tick>(_onTick);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(const _Tick()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) {
    emit(VideoState(videos: state.videos, currentGroupId: event.groupId));
  }

  void _onAddVideo(AddVideo event, Emitter<VideoState> emit) {
    final updatedVideos = List<Video>.from(state.videos)..add(event.video);
    emit(VideoState(videos: updatedVideos, currentGroupId: state.currentGroupId));
  }

  void _onDeleteVideo(DeleteVideo event, Emitter<VideoState> emit) {
    final updatedVideos = state.videos.where((v) => v.id != event.videoId).toList();
    emit(VideoState(videos: updatedVideos, currentGroupId: state.currentGroupId));
  }

  void _onToggleVideo(ToggleVideo event, Emitter<VideoState> emit) {
    final updatedVideos = state.videos.map((v) {
      return v.id == event.videoId ? v.copyWith(isEnabled: event.isEnabled) : v;
    }).toList();
    emit(VideoState(videos: updatedVideos, currentGroupId: state.currentGroupId));
  }

  void _onSetTimer(SetTimer event, Emitter<VideoState> emit) {
    final updatedVideos = state.videos.map((v) {
      return v.id == event.videoId ? v.copyWith(timerDurationSeconds: event.durationSeconds) : v;
    }).toList();
    emit(VideoState(videos: updatedVideos, currentGroupId: state.currentGroupId));
  }

  void _onStartTimer(StartTimer event, Emitter<VideoState> emit) {
    final updatedVideos = state.videos.map((v) {
      if (v.id == event.videoId) {
        return v.copyWith(
          timerEndTime: DateTime.now().add(Duration(seconds: v.timerDurationSeconds)),
        );
      }
      return v;
    }).toList();
    emit(VideoState(videos: updatedVideos, currentGroupId: state.currentGroupId));
  }

  void _onStopTimer(StopTimer event, Emitter<VideoState> emit) {
    final updatedVideos = state.videos.map((v) {
      // We can't easily "unset" a nullable field in copyWith if we don't handle null explicitly in copyWith logic
      // But my copyWith implementation uses `?? this.field`, so passing null won't work to clear it.
      // I need to fix copyWith or just reconstruct the object.
      // Actually, let's just reconstruct it for safety here.
      if (v.id == event.videoId) {
        return Video(
          id: v.id,
          groupId: v.groupId,
          title: v.title,
          isEnabled: v.isEnabled,
          timerDurationSeconds: v.timerDurationSeconds,
          timerEndTime: null, // Explicitly null
          filePath: v.filePath,
          assignedStudentIds: v.assignedStudentIds,
          isForAllStudents: v.isForAllStudents,
        );
      }
      return v;
    }).toList();
    emit(VideoState(videos: updatedVideos, currentGroupId: state.currentGroupId));
  }

  void _onTick(_Tick event, Emitter<VideoState> emit) {
    // Just emit state to trigger UI rebuilds for timers
    // We could optimize this to only emit if there are active timers
    if (state.videos.any((v) => v.timerEndTime != null)) {
       emit(VideoState(videos: state.videos, currentGroupId: state.currentGroupId));
    }
  }

  @override
  VideoState? fromJson(Map<String, dynamic> json) => VideoState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(VideoState state) => state.toJson();
}
