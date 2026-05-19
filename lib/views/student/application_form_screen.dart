/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : application_form_screen.dart
 */

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../models/module_model.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/shared_widgets.dart';

class ApplicationFormScreen extends StatefulWidget {
  final ApplicationModel? existingApplication;
  const ApplicationFormScreen({super.key, this.existingApplication});

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingApplication != null;
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appVM = context.read<ApplicationViewModel>();
      await appVM.loadModules();
      if (_isEditing) {
        appVM.initFormForEdit(widget.existingApplication!);
      } else {
        appVM.resetForm();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        context.read<ApplicationViewModel>().setDocumentFile(
              File(result.files.single.path!),
              result.files.single.name,
            );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to pick file: $e',
            isError: true);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthViewModel>();
    final appVM = context.read<ApplicationViewModel>();

    bool success;
    if (_isEditing) {
      success = await appVM.updateApplication(
          widget.existingApplication!.id, auth.profile!.id);
    } else {
      success = await appVM.submitApplication(auth.profile!.id);
    }

    if (!mounted) return;
    if (success) {
      showAppSnackBar(
        context,
        _isEditing
            ? 'Application updated successfully!'
            : 'Application submitted successfully!',
        isSuccess: true,
      );
      Navigator.pop(context);
    } else if (appVM.errorMessage != null) {
      showAppSnackBar(context, appVM.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---- HEADER ----
              FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing
                                ? 'Edit Application'
                                : 'New Application',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            _isEditing
                                ? 'Update your application details'
                                : 'Apply for Student Assistant',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---- FORM ----
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32)),
                  ),
                  child: Consumer<ApplicationViewModel>(
                    builder: (_, appVM, __) {
                      if (appVM.modules.isEmpty && appVM.isLoading) {
                        return const AppLoadingIndicator(
                            message: 'Loading modules...');
                      }

                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Handle bar
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Guidelines
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.06),
                                      AppColors.primaryLight
                                          .withOpacity(0.06),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.primary
                                          .withOpacity(0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                              Icons.info_outline_rounded,
                                              color: AppColors.primary,
                                              size: 16),
                                        ),
                                        const SizedBox(width: 10),
                                        Text('Application Guidelines',
                                            style: AppTextStyles.heading3),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '• You may apply to assist with up to 2 modules.\n'
                                      '• Ensure you meet the minimum academic requirements.\n'
                                      '• Upload supporting documentation (academic transcript).\n'
                                      '• Only one application is permitted per student.',
                                      style: AppTextStyles.bodySecondary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Personal Info
                              _SectionHeader(
                                  icon: Icons.person_outline_rounded,
                                  title: 'Personal Information'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.divider),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Current Year of Study',
                                        style: AppTextStyles.label),
                                    const SizedBox(height: 10),
                                    _YearSelector(
                                      selected: appVM.selectedYearOfStudy,
                                      onChanged: appVM.setYearOfStudy,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Primary Module
                              _SectionHeader(
                                  icon: Icons.book_outlined,
                                  title: 'Primary Module Application'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.divider),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Academic Level',
                                        style: AppTextStyles.label),
                                    const SizedBox(height: 10),
                                    _LevelSelector(
                                      selected: appVM.selectedModule1Level,
                                      onChanged: (level) {
                                        appVM.setModule1Level(level);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Module',
                                        style: AppTextStyles.label),
                                    const SizedBox(height: 10),
                                    _ModuleDropdown(
                                      modules: appVM.modulesForLevel1,
                                      selected: appVM.selectedModule1,
                                      onChanged: appVM.setModule1,
                                      hint: 'Select a module',
                                      validator: (val) => val == null
                                          ? 'Please select a module'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Second Module
                              _SectionHeader(
                                  icon: Icons.add_circle_outline_rounded,
                                  title: 'Second Module (Optional)'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.divider),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Switch(
                                          value: appVM.addSecondModule,
                                          onChanged:
                                              appVM.toggleSecondModule,
                                          activeColor: AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Apply for a second module',
                                            style: AppTextStyles.body,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (appVM.addSecondModule) ...[
                                      const SizedBox(height: 16),
                                      Text('Academic Level',
                                          style: AppTextStyles.label),
                                      const SizedBox(height: 10),
                                      _LevelSelector(
                                        selected:
                                            appVM.selectedModule2Level ??
                                                1,
                                        onChanged: (level) {
                                          appVM.setModule2Level(level);
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Text('Module',
                                          style: AppTextStyles.label),
                                      const SizedBox(height: 10),
                                      _ModuleDropdown(
                                        modules: appVM.modulesForLevel2,
                                        selected: appVM.selectedModule2,
                                        onChanged: appVM.setModule2,
                                        hint: 'Select a second module',
                                        validator: (val) =>
                                            appVM.addSecondModule &&
                                                    val == null
                                                ? 'Please select a module'
                                                : null,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Eligibility
                              _SectionHeader(
                                  icon: Icons.verified_outlined,
                                  title: 'Eligibility & Documentation'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.divider),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Checkbox
                                    Container(
                                      decoration: BoxDecoration(
                                        color: appVM.meetsRequirements
                                            ? AppColors.success
                                                .withOpacity(0.05)
                                            : AppColors.background,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: appVM.meetsRequirements
                                              ? AppColors.success
                                                  .withOpacity(0.3)
                                              : AppColors.divider,
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        value: appVM.meetsRequirements,
                                        onChanged: (val) => appVM
                                            .setMeetsRequirements(
                                                val ?? false),
                                        title: const Text(
                                          'I confirm that I meet the minimum requirements',
                                          style: TextStyle(
                                              fontSize: 13, height: 1.4),
                                        ),
                                        subtitle: const Text(
                                          'Requirements include a minimum pass mark in the relevant module.',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  AppColors.textSecondary),
                                        ),
                                        activeColor: AppColors.success,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Document upload
                                    Text('Supporting Documentation',
                                        style: AppTextStyles.label),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload your academic transcript (PDF, JPG, PNG)',
                                      style: AppTextStyles.bodySecondary
                                          .copyWith(fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: _pickDocument,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: appVM.documentName !=
                                                  null
                                              ? LinearGradient(
                                                  colors: [
                                                    AppColors.success
                                                        .withOpacity(0.05),
                                                    AppColors.success
                                                        .withOpacity(0.1),
                                                  ],
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    AppColors.primary
                                                        .withOpacity(0.04),
                                                    AppColors.primaryLight
                                                        .withOpacity(0.04),
                                                  ],
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: appVM.documentName !=
                                                    null
                                                ? AppColors.success
                                                : AppColors.primary
                                                    .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: appVM.documentName !=
                                                        null
                                                    ? AppColors.success
                                                        .withOpacity(0.1)
                                                    : AppColors.primary
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                              ),
                                              child: Icon(
                                                appVM.documentName != null
                                                    ? Icons
                                                        .check_circle_outline_rounded
                                                    : Icons
                                                        .upload_file_rounded,
                                                color: appVM.documentName !=
                                                        null
                                                    ? AppColors.success
                                                    : AppColors.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                appVM.documentName ??
                                                    'Tap to upload document',
                                                style: TextStyle(
                                                  color: appVM.documentName !=
                                                          null
                                                      ? AppColors.textPrimary
                                                      : AppColors
                                                          .textSecondary,
                                                  fontSize: 13,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (appVM.documentName != null)
                                              TextButton(
                                                onPressed: _pickDocument,
                                                child: const Text('Change',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Submit button
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isEditing
                                        ? [
                                            AppColors.primary,
                                            AppColors.primaryLight,
                                          ]
                                        : [
                                            AppColors.accent,
                                            AppColors.accentLight,
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isEditing
                                              ? AppColors.primary
                                              : AppColors.accent)
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: appVM.isLoading
                                        ? null
                                        : _handleSubmit,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      child: Center(
                                        child: appVM.isLoading
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                _isEditing
                                                    ? 'Update Application'
                                                    : 'Submit Application',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.heading3),
      ],
    );
  }
}

class _YearSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _YearSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [1, 2, 3].map((year) {
        final isSelected = selected == year;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  'Year $year',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _LevelSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [1, 2, 3].map((level) {
        final isSelected = selected == level;
        return GestureDetector(
          onTap: () => onChanged(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isSelected ? AppColors.primary : AppColors.divider,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Text(
              'Year $level',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ModuleDropdown extends StatelessWidget {
  final List<ModuleModel> modules;
  final ModuleModel? selected;
  final ValueChanged<ModuleModel?> onChanged;
  final String hint;
  final FormFieldValidator<ModuleModel>? validator;

  const _ModuleDropdown({
    required this.modules,
    required this.selected,
    required this.onChanged,
    required this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ModuleModel>(
      value: selected,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      isExpanded: true,
      items: modules.map((module) {
        return DropdownMenuItem(
          value: module,
          child: Text(
            module.displayName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      hint: Text(hint, style: AppTextStyles.bodySecondary),
    );
  }
}