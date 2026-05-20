/**
 * student name: Sinekhaya Vatsha/ 
 * studentNo: 222044842/
 */

class ModuleModel {
  final String id;
  final String code;
  final String name;
  final int academicLevel;
  final DateTime createdAt;

  ModuleModel({
    required this.id,
    required this.code,
    required this.name,
    required this.academicLevel,
    required this.createdAt,
  });

  String get displayName => '$code - $name';
  String get levelLabel => 'Year $academicLevel';

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      academicLevel: json['academic_level'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'academic_level': academicLevel,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModuleModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
