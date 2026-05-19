/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : admin_viewmodel.dart
 */

import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/supabase_service.dart';

enum AdminViewState { idle, loading, success, error }

class AdminViewModel extends ChangeNotifier {
  AdminViewState _state = AdminViewState.idle;
  String? _errorMessage;
  String? _successMessage;
  List<ApplicationModel> _applications = [];
  ApplicationModel? _selectedApplication;
  String _statusFilter = 'all';

  AdminViewState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == AdminViewState.loading;
  List<ApplicationModel> get applications => _applications;
  ApplicationModel? get selectedApplication => _selectedApplication;
  String get statusFilter => _statusFilter;

  int get pendingCount =>
      _applications.where((a) => a.status == ApplicationStatus.pending).length;
  int get approvedCount =>
      _applications.where((a) => a.status == ApplicationStatus.approved).length;
  int get rejectedCount =>
      _applications.where((a) => a.status == ApplicationStatus.rejected).length;

  Future<void> loadAllApplications() async {
    _setState(AdminViewState.loading);
    try {
      _applications = await SupabaseService.fetchAllApplications(
        statusFilter: _statusFilter,
      );
      _setState(AdminViewState.success);
    } catch (e) {
      _errorMessage = 'Failed to load applications: $e';
      _setState(AdminViewState.error);
    }
  }

  Future<void> loadApplicationById(String id) async {
    _setState(AdminViewState.loading);
    try {
      _selectedApplication = await SupabaseService.fetchApplicationById(id);
      _setState(AdminViewState.success);
    } catch (e) {
      _errorMessage = 'Failed to load application details: $e';
      _setState(AdminViewState.error);
    }
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    loadAllApplications();
  }

  Future<bool> approveApplication(
    String applicationId,
    String adminId, {
    String? comments,
  }) async {
    return await _updateStatus(
      applicationId: applicationId,
      status: 'approved',
      adminId: adminId,
      comments: comments,
    );
  }

  Future<bool> rejectApplication(
    String applicationId,
    String adminId, {
    String? comments,
  }) async {
    return await _updateStatus(
      applicationId: applicationId,
      status: 'rejected',
      adminId: adminId,
      comments: comments,
    );
  }

  Future<bool> _updateStatus({
    required String applicationId,
    required String status,
    required String adminId,
    String? comments,
  }) async {
    _setState(AdminViewState.loading);
    try {
      await SupabaseService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
        adminComments: comments,
        reviewedBy: adminId,
      );

      final idx = _applications.indexWhere((a) => a.id == applicationId);
      if (idx >= 0) {
        await loadAllApplications();
      }
      if (_selectedApplication?.id == applicationId) {
        _selectedApplication = await SupabaseService.fetchApplicationById(applicationId);
      }

      _successMessage =
          'Application ${status == 'approved' ? 'approved' : 'rejected'} successfully.';
      _setState(AdminViewState.success);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update application status: $e';
      _setState(AdminViewState.error);
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    _setState(AdminViewState.loading);
    try {
      await SupabaseService.deleteApplication(applicationId);
      _applications.removeWhere((a) => a.id == applicationId);
      _selectedApplication = null;
      _successMessage = 'Application removed successfully.';
      _setState(AdminViewState.success);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application: $e';
      _setState(AdminViewState.error);
      return false;
    }
  }

  void setSelectedApplication(ApplicationModel? app) {
    _selectedApplication = app;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setState(AdminViewState s) {
    _state = s;
    notifyListeners();
  }
}
