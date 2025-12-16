import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/group.dart';

// Events
abstract class GroupEvent extends Equatable {
  const GroupEvent();
  @override
  List<Object> get props => [];
}

class LoadGroups extends GroupEvent {}

class AddGroup extends GroupEvent {
  final CourseGroup group;
  const AddGroup(this.group);
  @override
  List<Object> get props => [group];
}

// State
class GroupState extends Equatable {
  final List<CourseGroup> groups;
  
  const GroupState({this.groups = const []});
  
  @override
  List<Object> get props => [groups];

  Map<String, dynamic> toJson() {
    return {'groups': groups.map((g) => g.toJson()).toList()};
  }

  factory GroupState.fromJson(Map<String, dynamic> json) {
    return GroupState(
      groups: (json['groups'] as List)
          .map((e) => CourseGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// BLoC
class GroupBloc extends HydratedBloc<GroupEvent, GroupState> {
  GroupBloc() : super(const GroupState()) {
    on<LoadGroups>(_onLoadGroups);
    on<AddGroup>(_onAddGroup);
  }

  void _onLoadGroups(LoadGroups event, Emitter<GroupState> emit) {
    if (state.groups.isEmpty) {
      // Seed initial groups
      emit(GroupState(groups: [
        const CourseGroup(id: '1', name: 'Web Development', description: 'HTML, CSS, JS, React'),
        const CourseGroup(id: '2', name: 'Artificial Intelligence', description: 'ML, Python, Neural Networks'),
        const CourseGroup(id: '3', name: 'English', description: 'Grammar, Speaking, Writing'),
      ]));
    }
  }

  void _onAddGroup(AddGroup event, Emitter<GroupState> emit) {
    final updatedGroups = List<CourseGroup>.from(state.groups)..add(event.group);
    emit(GroupState(groups: updatedGroups));
  }

  @override
  GroupState? fromJson(Map<String, dynamic> json) => GroupState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(GroupState state) => state.toJson();
}
