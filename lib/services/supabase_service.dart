/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : supabase_service.dart
 */

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../models/module_model.dart';
import '../models/profile_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  // =============================================
  // AUTHENTICATION
  // =============================================

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    required String role,
    required int yearOfStudy,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'student_number': studentNumber,
        'role': role,
        'year_of_study': yearOfStudy,
      },
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // =============================================
  // PROFILES
  // =============================================

  static Future<ProfileModel?> fetchProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return ProfileModel.fromJson(response);
  }

  static Future<void> updateProfile(ProfileModel profile) async {
    await client.from('profiles').update({
      'full_name': profile.fullName,
      'student_number': profile.studentNumber,
      'year_of_study': profile.yearOfStudy,
    }).eq('id', profile.id);
  }

  // =============================================
  // MODULES
  // =============================================

  static Future<List<ModuleModel>> fetchModules({int? level}) async {
    var query = client.from('modules').select();
    if (level != null) {
      query = query.eq('academic_level', level) as dynamic;
    }
    final response = await query.order('academic_level').order('code');
    return (response as List)
        .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // =============================================
  // APPLICATIONS - STUDENT
  // =============================================

  static Future<List<ApplicationModel>> fetchStudentApplications(
      String studentId) async {
    final response = await client
        .from('applications')
        .select('''
          *,
          module1:modules!applications_module1_id_fkey(*),
          module2:modules!applications_module2_id_fkey(*),
          profiles!applications_student_id_fkey(*)
        ''')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ApplicationModel?> fetchApplicationById(String id) async {
    final response = await client
        .from('applications')
        .select('''
          *,
          module1:modules!applications_module1_id_fkey(*),
          module2:modules!applications_module2_id_fkey(*),
          profiles!applications_student_id_fkey(*)
        ''')
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return ApplicationModel.fromJson(response);
  }

  static Future<bool> studentHasApplication(String studentId) async {
    final response = await client
        .from('applications')
        .select('id')
        .eq('student_id', studentId);
    return (response as List).isNotEmpty;
  }

  static Future<ApplicationModel> createApplication(
      ApplicationModel application) async {
    final response = await client
        .from('applications')
        .insert(application.toInsertJson())
        .select('''
          *,
          module1:modules!applications_module1_id_fkey(*),
          module2:modules!applications_module2_id_fkey(*)
        ''')
        .single();
    return ApplicationModel.fromJson(response);
  }

  static Future<ApplicationModel> updateApplication(
      String id, ApplicationModel application) async {
    final response = await client
        .from('applications')
        .update(application.toUpdateJson())
        .eq('id', id)
        .select('''
          *,
          module1:modules!applications_module1_id_fkey(*),
          module2:modules!applications_module2_id_fkey(*)
        ''')
        .single();
    return ApplicationModel.fromJson(response);
  }

  static Future<void> deleteApplication(String id) async {
    await client.from('applications').delete().eq('id', id);
  }

  // =============================================
  // APPLICATIONS - ADMIN
  // =============================================

  static Future<List<ApplicationModel>> fetchAllApplications(
      {String? statusFilter}) async {
    var query = client.from('applications').select('''
          *,
          module1:modules!applications_module1_id_fkey(*),
          module2:modules!applications_module2_id_fkey(*),
          profiles!applications_student_id_fkey(*)
        ''');
    if (statusFilter != null && statusFilter != 'all') {
      query = query.eq('status', statusFilter) as dynamic;
    }
    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? adminComments,
    required String reviewedBy,
  }) async {
    await client.from('applications').update({
      'status': status,
      'admin_comments': adminComments,
      'reviewed_by': reviewedBy,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', applicationId);
  }

  // =============================================
  // FILE STORAGE — disabled on web
  // =============================================

  static Future<String?> uploadDocument(dynamic file, String userId) async {
    return null;
  }

  static Future<String> getDocumentSignedUrl(String path) async {
    return await client.storage
        .from('documents')
        .createSignedUrl(path, 3600);
  }
}
