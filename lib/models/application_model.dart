/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : application_model.dart
 */

import 'package:flutter/material.dart';
import 'module_model.dart';
import 'profile_model.dart';

enum ApplicationStatus { pending, approved, rejected }

extension ApplicationStatusExtension on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return const Color(0xFF1565C0);
      case ApplicationStatus.approved:
        return const Color(0xFF2E7D32);
      case ApplicationStatus.rejected:
        return const Color(0xFFD32F2F);
    }
  }

  Color get bgColor {
    switch (this) {
      case ApplicationStatus.pending:
        return const Color(0xFFE3F2FD);
      case ApplicationStatus.approved:
        return const Color(0xFFE8F5E9);
      case ApplicationStatus.rejected:
        return const Color(0xFFFFEBEE);
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ApplicationStatus.approved:
        return Icons.check_circle_rounded;
      case ApplicationStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class ApplicationModel {
  final String id;
  final String studentId;
  final int yearOfStudy;

  final String module1Id;
  final int module1Level;
  final ModuleModel? module1;

  final String? module2Id;
  final int? module2Level;
  final ModuleModel? module2;

  final bool meetsRequirements;
  final String? documentUrl;
  final String? documentName;

  final ApplicationStatus status;
  final String? adminComments;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final ProfileModel? student;

  ApplicationModel({
    required this.id,
    required this.studentId,
    required this.yearOfStudy,
    required this.module1Id,
    required this.module1Level,
    this.module1,
    this.module2Id,
    this.module2Level,
    this.module2,
    required this.meetsRequirements,
    this.documentUrl,
    this.documentName,
    required this.status,
    this.adminComments,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.student,
  });

  bool get isPending => status == ApplicationStatus.pending;
  bool get hasSecondModule => module2Id != null;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    ApplicationStatus parseStatus(String s) {
      switch (s) {
        case 'approved':
          return ApplicationStatus.approved;
        case 'rejected':
          return ApplicationStatus.rejected;
        default:
          return ApplicationStatus.pending;
      }
    }

    return ApplicationModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      yearOfStudy: json['year_of_study'] as int,
      module1Id: json['module1_id'] as String,
      module1Level: json['module1_level'] as int,
      module1: json['module1'] != null
          ? ModuleModel.fromJson(json['module1'] as Map<String, dynamic>)
          : null,
      module2Id: json['module2_id'] as String?,
      module2Level: json['module2_level'] as int?,
      module2: json['module2'] != null
          ? ModuleModel.fromJson(json['module2'] as Map<String, dynamic>)
          : null,
      meetsRequirements: json['meets_requirements'] as bool? ?? false,
      documentUrl: json['document_url'] as String?,
      documentName: json['document_name'] as String?,
      status: parseStatus(json['status'] as String? ?? 'pending'),
      adminComments: json['admin_comments'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      student: json['profiles'] != null
          ? ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'student_id': studentId,
        'year_of_study': yearOfStudy,
        'module1_id': module1Id,
        'module1_level': module1Level,
        'module2_id': module2Id,
        'module2_level': module2Level,
        'meets_requirements': meetsRequirements,
        'document_url': documentUrl,
        'document_name': documentName,
        'status': status.name,
      };

  Map<String, dynamic> toUpdateJson() => {
        'year_of_study': yearOfStudy,
        'module1_id': module1Id,
        'module1_level': module1Level,
        'module2_id': module2Id,
        'module2_level': module2Level,
        'meets_requirements': meetsRequirements,
        'document_url': documentUrl,
        'document_name': documentName,
      };
}
