/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : profile_model.dart
 */

class ProfileModel {
  final String id;
  final String fullName;
  final String? studentNumber;
  final String email;
  final String role; // 'student' or 'admin'
  final int? yearOfStudy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.studentNumber,
    required this.email,
    required this.role,
    this.yearOfStudy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      studentNumber: json['student_number'] as String?,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'student',
      yearOfStudy: json['year_of_study'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'student_number': studentNumber,
        'email': email,
        'role': role,
        'year_of_study': yearOfStudy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ProfileModel copyWith({
    String? fullName,
    String? studentNumber,
    int? yearOfStudy,
  }) =>
      ProfileModel(
        id: id,
        fullName: fullName ?? this.fullName,
        studentNumber: studentNumber ?? this.studentNumber,
        email: email,
        role: role,
        yearOfStudy: yearOfStudy ?? this.yearOfStudy,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
