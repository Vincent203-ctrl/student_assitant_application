/**
 * Student Numbers: 210070123, 210070456, 210070789, 210070111, 210070222
 * Student Names  : John Doe, Jane Smith, Clark Kent, Bruce Lee, Diana Prince
 * File           : admin_application_detail_screen.dart
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/shared_widgets.dart';
import '../../models/application_model.dart';

class AdminApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  const AdminApplicationDetailScreen(
      {super.key, required this.applicationId});

  @override
  State<AdminApplicationDetailScreen> createState() =>
      _AdminApplicationDetailScreenState();
}

class _AdminApplicationDetailScreenState
    extends State<AdminApplicationDetailScreen>
    with TickerProviderStateMixin {
  final _commentsCtrl = TextEditingController();

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

    WidgetsBinding.instance.addPostFrameCallback((_) => context
        .read<AdminViewModel>()
        .loadApplicationById(widget.applicationId));
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    final vm = context.read<AdminViewModel>();
    final auth = context.read<AuthViewModel>();

    final label = status == 'approved' ? 'Approve' : 'Reject';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('$label Application',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to $label this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved'
                  ? AppColors.success
                  : AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(label,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final success = status == 'approved'
        ? await vm.approveApplication(
            widget.applicationId, auth.profile!.id,
            comments: _commentsCtrl.text.trim().isNotEmpty
                ? _commentsCtrl.text.trim()
                : null)
        : await vm.rejectApplication(
            widget.applicationId, auth.profile!.id,
            comments: _commentsCtrl.text.trim().isNotEmpty
                ? _commentsCtrl.text.trim()
                : null);

    if (!mounted) return;
    if (success) {
      showAppSnackBar(
        context,
        'Application ${status == 'approved' ? 'approved' : 'rejected'} successfully.',
        isSuccess: true,
      );
    } else if (vm.errorMessage != null) {
      showAppSnackBar(context, vm.errorMessage!, isError: true);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Application',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to permanently remove this application?'),
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
            child: const Text('Remove',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final vm = context.read<AdminViewModel>();
    final success = await vm.deleteApplication(widget.applicationId);
    if (!mounted) return;
    if (success) {
      showAppSnackBar(context, 'Application removed.', isSuccess: true);
      Navigator.pop(context);
    } else {
      showAppSnackBar(context, vm.errorMessage ?? 'Delete failed.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (_, vm, __) {
        final app = vm.selectedApplication;
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
                      padding:
                          const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                                  'Application Review',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Review and manage application',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (app != null)
                            GestureDetector(
                              onTap: _delete,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 20),
                              ),
                            ),
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
                      child: vm.isLoading
                          ? const AppLoadingIndicator()
                          : app == null
                              ? AppErrorWidget(
                                  message: 'Application not found.',
                                  onRetry: () => vm.loadApplicationById(
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

                                      // Status banner
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
                                                  BorderRadius.circular(
                                                      12),
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
                                              Text('Current Status',
                                                  style: AppTextStyles
                                                      .label
                                                      .copyWith(
                                                          color: app.status
                                                              .color)),
                                              Text(
                                                app.status.label,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color:
                                                        app.status.color),
                                              ),
                                            ],
                                          ),
                                        ]),
                                      ),
                                      const SizedBox(height: 20),

                                      // Student info
                                      _SectionHeader(
                                          icon: Icons.person_outline_rounded,
                                          title: 'Student Information'),
                                      const SizedBox(height: 12),
                                      _InfoCard(children: [
                                        InfoRow(
                                            label: 'FULL NAME',
                                            value: app.student?.fullName ??
                                                'Unknown',
                                            icon: Icons.badge_outlined),
                                        const Divider(height: 20),
                                        InfoRow(
                                            label: 'STUDENT NUMBER',
                                            value: app.student
                                                    ?.studentNumber ??
                                                'N/A',
                                            icon: Icons.numbers_rounded),
                                        const Divider(height: 20),
                                        InfoRow(
                                            label: 'EMAIL',
                                            value:
                                                app.student?.email ?? 'N/A',
                                            icon: Icons.email_outlined),
                                        const Divider(height: 20),
                                        InfoRow(
                                            label: 'YEAR OF STUDY',
                                            value:
                                                'Year ${app.yearOfStudy}',
                                            icon: Icons.school_outlined),
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
                                            value:
                                                app.module1?.displayName ??
                                                    'Unknown',
                                            icon: Icons.class_outlined),
                                        const Divider(height: 20),
                                        InfoRow(
                                            label: 'LEVEL',
                                            value:
                                                'Year ${app.module1Level}',
                                            icon:
                                                Icons.trending_up_rounded),
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
                                              value: app.module2
                                                      ?.displayName ??
                                                  'Unknown',
                                              icon: Icons.class_outlined),
                                          const Divider(height: 20),
                                          InfoRow(
                                              label: 'LEVEL',
                                              value:
                                                  'Year ${app.module2Level}',
                                              icon: Icons
                                                  .trending_up_rounded),
                                        ]),
                                      ],
                                      const SizedBox(height: 20),

                                      // Eligibility
                                      _SectionHeader(
                                          icon: Icons.verified_outlined,
                                          title:
                                              'Eligibility & Documentation'),
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
                                                  ? Icons
                                                      .check_circle_rounded
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
                                                  ? 'Student confirmed eligibility'
                                                  : 'Student did not confirm eligibility',
                                              style: AppTextStyles.body,
                                            ),
                                          ),
                                        ]),
                                        if (app.documentName != null) ...[
                                          const Divider(height: 20),
                                          Row(children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                              ),
                                              child: const Icon(
                                                  Icons.attach_file_rounded,
                                                  size: 16,
                                                  color: AppColors.primary),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                  app.documentName!,
                                                  style: AppTextStyles.body,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ]),
                                        ],
                                      ]),
                                      const SizedBox(height: 20),

                                      // Submission details
                                      _SectionHeader(
                                          icon: Icons.info_outline_rounded,
                                          title: 'Submission Details'),
                                      const SizedBox(height: 12),
                                      _InfoCard(children: [
                                        InfoRow(
                                            label: 'SUBMITTED',
                                            value: DateFormat(
                                                    'dd MMM yyyy – HH:mm')
                                                .format(app.createdAt),
                                            icon: Icons
                                                .calendar_today_outlined),
                                        if (app.reviewedAt != null) ...[
                                          const Divider(height: 20),
                                          InfoRow(
                                              label: 'REVIEWED',
                                              value: DateFormat(
                                                      'dd MMM yyyy – HH:mm')
                                                  .format(app.reviewedAt!),
                                              icon:
                                                  Icons.rate_review_outlined),
                                        ],
                                      ]),
                                      const SizedBox(height: 20),

                                      // Admin comments
                                      if (app.isPending) ...[
                                        _SectionHeader(
                                            icon: Icons.comment_outlined,
                                            title:
                                                'Admin Comments (Optional)'),
                                        const SizedBox(height: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
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
                                          child: TextFormField(
                                            controller: _commentsCtrl,
                                            maxLines: 3,
                                            decoration: const InputDecoration(
                                              hintText:
                                                  'Enter comments or reason for decision...',
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(16),
                                            ),
                                          ),
                                        ),
                                      ] else if (app.adminComments !=
                                          null) ...[
                                        _SectionHeader(
                                            icon: Icons.comment_outlined,
                                            title: 'Admin Comments'),
                                        const SizedBox(height: 12),
                                        _InfoCard(children: [
                                          Text(app.adminComments!,
                                              style: AppTextStyles.body),
                                        ]),
                                      ],

                                      // Approve / Reject buttons
                                      if (app.isPending) ...[
                                        const SizedBox(height: 28),
                                        Row(children: [
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
                                                    BorderRadius.circular(
                                                        14),
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
                                                  onTap: vm.isLoading
                                                      ? null
                                                      : () => _updateStatus(
                                                          'rejected'),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 16),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .cancel_outlined,
                                                            color:
                                                                Colors.white,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Reject',
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
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.success,
                                                    AppColors.success
                                                        .withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        14),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.success
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
                                                  onTap: vm.isLoading
                                                      ? null
                                                      : () => _updateStatus(
                                                          'approved'),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 16),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .check_circle_outline_rounded,
                                                            color:
                                                                Colors.white,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Approve',
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