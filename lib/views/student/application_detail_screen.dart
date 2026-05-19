/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : application_detail_screen.dart
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../shared/shared_widgets.dart';
import 'application_form_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ApplicationViewModel>()
          .loadApplicationById(widget.applicationId);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Application',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to delete this application? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      final appVM = context.read<ApplicationViewModel>();
      final success = await appVM.deleteApplication(widget.applicationId);
      if (!mounted) return;
      if (success) {
        showAppSnackBar(context, 'Application deleted.', isSuccess: true);
        Navigator.pop(context);
      } else {
        showAppSnackBar(
            context, appVM.errorMessage ?? 'Delete failed.',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationViewModel>(
      builder: (_, appVM, __) {
        final app = appVM.selectedApplication;
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Application Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'View your application status',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (app != null && app.isPending) ...[
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ApplicationFormScreen(
                                      existingApplication: app,
                                    ),
                                  ),
                                );
                                if (mounted) {
                                  context
                                      .read<ApplicationViewModel>()
                                      .loadApplicationById(
                                          widget.applicationId);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: const Icon(Icons.edit_outlined,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _handleDelete,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 20),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ---- CONTENT ----
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32)),
                      ),
                      child: appVM.isLoading
                          ? const AppLoadingIndicator(
                              message: 'Loading application details...')
                          : app == null
                              ? AppErrorWidget(
                                  message: 'Application not found.',
                                  onRetry: () => context
                                      .read<ApplicationViewModel>()
                                      .loadApplicationById(
                                          widget.applicationId),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 24, 20, 28),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Handle bar
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColors.divider,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Status Banner
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              app.status.bgColor,
                                              app.status.bgColor
                                                  .withOpacity(0.5),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: app.status.color
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Row(children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: app.status.color
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(app.status.icon,
                                                color: app.status.color,
                                                size: 24),
                                          ),
                                          const SizedBox(width: 14),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Application Status',
                                                  style: AppTextStyles.label
                                                      .copyWith(
                                                          color: app
                                                              .status.color)),
                                              Text(
                                                app.status.label,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: app.status.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                      ),
                                      const SizedBox(height: 20),

                                      // Application Info
                                      _SectionHeader(
                                          icon: Icons.assignment_outlined,
                                          title: 'Application Information'),
                                      const SizedBox(height: 12),
                                      _InfoCard(children: [
                                        InfoRow(
                                          label: 'YEAR OF STUDY',
                                          value: 'Year ${app.yearOfStudy}',
                                          icon: Icons.school_outlined,
                                        ),
                                        const Divider(height: 16),
                                        InfoRow(
                                          label: 'SUBMITTED ON',
                                          value: DateFormat(
                                                  'dd MMMM yyyy – HH:mm')
                                              .format(app.createdAt),
                                          icon: Icons.calendar_today_outlined,
                                        ),
                                        if (app.updatedAt !=
                                            app.createdAt) ...[
                                          const Divider(height: 16),
                                          InfoRow(
                                            label: 'LAST UPDATED',
                                            value: DateFormat(
                                                    'dd MMMM yyyy – HH:mm')
                                                .format(app.updatedAt),
                                            icon: Icons.update_rounded,
                                          ),
                                        ],
                                      ]),
                                      const SizedBox(height: 20),

                                      // Module 1
                                      _SectionHeader(
                                          icon: Icons.book_outlined,
                                          title: 'Primary Module'),
                                      const SizedBox(height: 12),
                                      _InfoCard(children: [
                                        InfoRow(
                                          label: 'MODULE',
                                          value: app.module1?.displayName ??
                                              'Module not found',
                                          icon: Icons.class_outlined,
                                        ),
                                        const Divider(height: 16),
                                        InfoRow(
                                          label: 'ACADEMIC LEVEL',
                                          value: 'Year ${app.module1Level}',
                                          icon: Icons.trending_up_rounded,
                                        ),
                                      ]),

                                      // Module 2
                                      if (app.hasSecondModule) ...[
                                        const SizedBox(height: 20),
                                        _SectionHeader(
                                            icon: Icons.add_box_outlined,
                                            title: 'Second Module'),
                                        const SizedBox(height: 12),
                                        _InfoCard(children: [
                                          InfoRow(
                                            label: 'MODULE',
                                            value:
                                                app.module2?.displayName ??
                                                    'Module not found',
                                            icon: Icons.class_outlined,
                                          ),
                                          const Divider(height: 16),
                                          InfoRow(
                                            label: 'ACADEMIC LEVEL',
                                            value:
                                                'Year ${app.module2Level}',
                                            icon: Icons.trending_up_rounded,
                                          ),
                                        ]),
                                      ],
                                      const SizedBox(height: 20),

                                      // Eligibility
                                      _SectionHeader(
                                          icon: Icons.verified_outlined,
                                          title: 'Eligibility'),
                                      const SizedBox(height: 12),
                                      _InfoCard(children: [
                                        Row(children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: (app.meetsRequirements
                                                      ? AppColors.success
                                                      : AppColors.error)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              app.meetsRequirements
                                                  ? Icons.check_circle_rounded
                                                  : Icons.cancel_rounded,
                                              color: app.meetsRequirements
                                                  ? AppColors.success
                                                  : AppColors.error,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              app.meetsRequirements
                                                  ? 'Student confirmed meeting minimum requirements'
                                                  : 'Student did not confirm eligibility',
                                              style: AppTextStyles.body,
                                            ),
                                          ),
                                        ]),
                                      ]),

                                      // Document
                                      if (app.documentName != null) ...[
                                        const SizedBox(height: 20),
                                        _SectionHeader(
                                            icon: Icons.attach_file_rounded,
                                            title: 'Supporting Document'),
                                        const SizedBox(height: 12),
                                        _InfoCard(children: [
                                          Row(children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                  Icons.description_outlined,
                                                  color: AppColors.primary,
                                                  size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                app.documentName!,
                                                style: AppTextStyles.body,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ]),
                                        ]),
                                      ],

                                      // Admin Review
                                      if (app.adminComments != null) ...[
                                        const SizedBox(height: 20),
                                        _SectionHeader(
                                            icon: Icons.rate_review_outlined,
                                            title: 'Admin Review'),
                                        const SizedBox(height: 12),
                                        _InfoCard(children: [
                                          Text('Comments',
                                              style: AppTextStyles.label),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(app.adminComments!,
                                                style: AppTextStyles.body),
                                          ),
                                          if (app.reviewedAt != null) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              'Reviewed on: ${DateFormat('dd MMM yyyy').format(app.reviewedAt!)}',
                                              style: AppTextStyles
                                                  .bodySecondary
                                                  .copyWith(fontSize: 11),
                                            ),
                                          ],
                                        ]),
                                      ],

                                      // Action buttons
                                      if (app.isPending) ...[
                                        const SizedBox(height: 28),
                                        Row(children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: AppColors.primary,
                                                    width: 1.8),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ApplicationFormScreen(
                                                          existingApplication:
                                                              app,
                                                        ),
                                                      ),
                                                    );
                                                    if (mounted) {
                                                      context
                                                          .read<ApplicationViewModel>()
                                                          .loadApplicationById(
                                                              widget.applicationId);
                                                    }
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 16),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons.edit_outlined,
                                                            color: AppColors
                                                                .primary,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 15,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.error,
                                                    AppColors.error
                                                        .withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.error
                                                        .withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset:
                                                        const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: _handleDelete,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 16),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .delete_outline_rounded,
                                                            color: Colors.white,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Delete',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 15,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}