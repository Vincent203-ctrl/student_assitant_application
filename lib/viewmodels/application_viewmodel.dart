/**
 * student name: Sinekhaya Vatsha/ 
 * studentNo: 222044842/
 */

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../models/module_model.dart';
import '../services/supabase_service.dart';

enum ViewState { idle, loading, success, error }

class ApplicationViewModel extends ChangeNotifier {
  // State
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  String? _successMessage;

  // Data
  List<ApplicationModel> _applications = [];
  List<ModuleModel> _modules = [];
  ApplicationModel? _selectedApplication;
  bool _hasExistingApplication = false;

  // Form state
  int _selectedYearOfStudy = 1;
  ModuleModel? _selectedModule1;
  int _selectedModule1Level = 1;
  ModuleModel? _selectedModule2;
  int? _selectedModule2Level = 1;
  bool _meetsRequirements = false;
  bool _addSecondModule = false;
  File? _documentFile;
  String? _documentName;

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<ApplicationModel> get applications => _applications;
  List<ModuleModel> get modules => _modules;
  ApplicationModel? get selectedApplication => _selectedApplication;
  bool get hasExistingApplication => _hasExistingApplication;
  bool get isLoading => _state == ViewState.loading;

  int get selectedYearOfStudy => _selectedYearOfStudy;
  ModuleModel? get selectedModule1 => _selectedModule1;
  int get selectedModule1Level => _selectedModule1Level;
  ModuleModel? get selectedModule2 => _selectedModule2;
  int? get selectedModule2Level => _selectedModule2Level;
  bool get meetsRequirements => _meetsRequirements;
  bool get addSecondModule => _addSecondModule;
  File? get documentFile => _documentFile;
  String? get documentName => _documentName;

  List<ModuleModel> get modulesForLevel1 =>
      _modules.where((m) => m.academicLevel == _selectedModule1Level).toList();

  List<ModuleModel> get modulesForLevel2 =>
      _modules.where((m) => m.academicLevel == (_selectedModule2Level ?? 1)).toList();

  // =============================================
  // LOAD DATA
  // =============================================

  Future<void> loadStudentData(String studentId) async {
    _setState(ViewState.loading);
    try {
      final results = await Future.wait([
        SupabaseService.fetchStudentApplications(studentId),
        SupabaseService.fetchModules(),
        SupabaseService.studentHasApplication(studentId),
      ]);
      _applications = results[0] as List<ApplicationModel>;
      _modules = results[1] as List<ModuleModel>;
      _hasExistingApplication = results[2] as bool;
      _setState(ViewState.success);
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      _setState(ViewState.error);
    }
  }

  Future<void> loadModules() async {
    try {
      _modules = await SupabaseService.fetchModules();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load modules: $e';
      notifyListeners();
    }
  }

  Future<void> loadApplicationById(String id) async {
    _setState(ViewState.loading);
    try {
      _selectedApplication = await SupabaseService.fetchApplicationById(id);
      _setState(ViewState.success);
    } catch (e) {
      _errorMessage = 'Failed to load application: $e';
      _setState(ViewState.error);
    }
  }

  // =============================================
  // FORM SETTERS
  // =============================================

  void setYearOfStudy(int year) {
    _selectedYearOfStudy = year;
    notifyListeners();
  }

  void setModule1Level(int level) {
    _selectedModule1Level = level;
    _selectedModule1 = null;
    notifyListeners();
  }

  void setModule1(ModuleModel? module) {
    _selectedModule1 = module;
    notifyListeners();
  }

  void setModule2Level(int? level) {
    _selectedModule2Level = level ?? 1;
    _selectedModule2 = null;
    notifyListeners();
  }

  void setModule2(ModuleModel? module) {
    _selectedModule2 = module;
    notifyListeners();
  }

  void setMeetsRequirements(bool value) {
    _meetsRequirements = value;
    notifyListeners();
  }

  void toggleSecondModule(bool value) {
    _addSecondModule = value;
    if (value) {
      _selectedModule2Level = 1;
    } else {
      _selectedModule2 = null;
      _selectedModule2Level = null;
    }
    notifyListeners();
  }

  void setDocumentFile(File file, String name) {
    _documentFile = file;
    _documentName = name;
    notifyListeners();
  }

  void initFormForEdit(ApplicationModel app) {
    _selectedYearOfStudy = app.yearOfStudy;
    _selectedModule1Level = app.module1Level;
    _selectedModule1 = app.module1;
    _selectedModule2Level = app.module2Level ?? 1;
    _selectedModule2 = app.module2;
    _meetsRequirements = app.meetsRequirements;
    _addSecondModule = app.hasSecondModule;
    _documentName = app.documentName;
    notifyListeners();
  }

  void resetForm() {
    _selectedYearOfStudy = 1;
    _selectedModule1 = null;
    _selectedModule1Level = 1;
    _selectedModule2 = null;
    _selectedModule2Level = 1;
    _meetsRequirements = false;
    _addSecondModule = false;
    _documentFile = null;
    _documentName = null;
    notifyListeners();
  }

  // =============================================
  // CRUD OPERATIONS
  // =============================================

  Future<bool> submitApplication(String studentId) async {
    if (_selectedModule1 == null) {
      _errorMessage = 'Please select a primary module.';
      notifyListeners();
      return false;
    }
    if (!_meetsRequirements) {
      _errorMessage =
          'You must confirm that you meet the eligibility requirements.';
      notifyListeners();
      return false;
    }
    if (_addSecondModule && _selectedModule2 == null) {
      _errorMessage =
          'Please select a second module or disable the second module option.';
      notifyListeners();
      return false;
    }

    _setState(ViewState.loading);
    try {
      String? docUrl;
      if (_documentFile != null) {
        docUrl =
            await SupabaseService.uploadDocument(_documentFile!, studentId);
      }

      final application = ApplicationModel(
        id: '',
        studentId: studentId,
        yearOfStudy: _selectedYearOfStudy,
        module1Id: _selectedModule1!.id,
        module1Level: _selectedModule1Level,
        module1: _selectedModule1,
        module2Id: _addSecondModule ? _selectedModule2?.id : null,
        module2Level: _addSecondModule ? _selectedModule2Level : null,
        module2: _addSecondModule ? _selectedModule2 : null,
        meetsRequirements: _meetsRequirements,
        documentUrl: docUrl,
        documentName: _documentName,
        status: ApplicationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await SupabaseService.createApplication(application);
      _applications.insert(0, created);
      _hasExistingApplication = true;
      _successMessage = 'Application submitted successfully!';
      resetForm();
      _setState(ViewState.success);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit application: $e';
      _setState(ViewState.error);
      return false;
    }
  }

  Future<bool> updateApplication(
      String applicationId, String studentId) async {
    if (_selectedModule1 == null) {
      _errorMessage = 'Please select a primary module.';
      notifyListeners();
      return false;
    }

    _setState(ViewState.loading);
    try {
      String? docUrl = _selectedApplication?.documentUrl;
      if (_documentFile != null) {
        docUrl =
            await SupabaseService.uploadDocument(_documentFile!, studentId);
      }

      final application = ApplicationModel(
        id: applicationId,
        studentId: studentId,
        yearOfStudy: _selectedYearOfStudy,
        module1Id: _selectedModule1!.id,
        module1Level: _selectedModule1Level,
        module1: _selectedModule1,
        module2Id: _addSecondModule ? _selectedModule2?.id : null,
        module2Level: _addSecondModule ? _selectedModule2Level : null,
        module2: _addSecondModule ? _selectedModule2 : null,
        meetsRequirements: _meetsRequirements,
        documentUrl: docUrl,
        documentName: _documentName ?? _selectedApplication?.documentName,
        status: ApplicationStatus.pending,
        createdAt: _selectedApplication?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated =
          await SupabaseService.updateApplication(applicationId, application);

      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index >= 0) _applications[index] = updated;
      _selectedApplication = updated;
      _successMessage = 'Application updated successfully!';
      _setState(ViewState.success);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update application: $e';
      _setState(ViewState.error);
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    _setState(ViewState.loading);
    try {
      await SupabaseService.deleteApplication(applicationId);
      _applications.removeWhere((a) => a.id == applicationId);
      _hasExistingApplication = _applications.isNotEmpty;
      _selectedApplication = null;
      _successMessage = 'Application deleted successfully.';
      _setState(ViewState.success);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application: $e';
      _setState(ViewState.error);
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setState(ViewState s) {
    _state = s;
    notifyListeners();
  }
}