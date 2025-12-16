import 'package:equatable/equatable.dart';

class CourseGroup extends Equatable {
  final String id;
  final String name;
  final String description;

  const CourseGroup({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, description];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory CourseGroup.fromJson(Map<String, dynamic> json) {
    return CourseGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
