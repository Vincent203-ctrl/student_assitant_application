/**
 * student name: Sinekhaya Vatsha/ 
 * studentNo: 222044842/
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_screen.dart';
import '../shared/shared_widgets.dart';
import 'application_form_screen.dart';
import 'application_detail_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthViewModel>();
    if (auth.profile == null) return;
    await context
        .read<ApplicationViewModel>()
        .loadStudentData(auth.profile!.id);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
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
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthViewModel>().signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final appVM = context.watch<ApplicationViewModel>();
    final profile = auth.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // ---- APP BAR ----
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.primary,
                // No actions here - buttons are in flexibleSpace only
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primary,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SA Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _loadData(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.refresh_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _handleLogout,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.logout_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  background: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.accent,
                                            AppColors.accentLight,
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accent
                                                .withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          (profile?.fullName ?? 'U')[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back,',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          profile?.fullName ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (profile?.studentNumber != null)
                                          Text(
                                            profile!.studentNumber!,
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Stats Row
                            Row(
                              children: [
                                _StatCard(
                                  label: 'Pending',
                                  count: appVM.applications
                                      .where((a) =>
                                          a.status ==
                                          ApplicationStatus.pending)
                                      .length,
                                  color: const Color(0xFF90CAF9),
                                  icon: Icons.hourglass_empty_rounded,
                                ),
                                const SizedBox(width: 8),
                                _StatCard(
                                  label: 'Approved',
                                  count: appVM.applications
                                      .where((a) =>
                                          a.status ==
                                          ApplicationStatus.approved)
                                      .length,
                                  color: const Color(0xFFA5D6A7),
                                  icon: Icons.check_circle_rounded,
                                ),
                                const SizedBox(width: 8),
                                _StatCard(
                                  label: 'Rejected',
                                  count: appVM.applications
                                      .where((a) =>
                                          a.status ==
                                          ApplicationStatus.rejected)
                                      .length,
                                  color: const Color(0xFFEF9A9A),
                                  icon: Icons.cancel_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Apply button or existing application notice
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildApplySection(appVM),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Applications list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('My Applications',
                          style: AppTextStyles.heading2),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${appVM.applications.length} total',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              if (appVM.isLoading)
                const SliverFillRemaining(
                  child: AppLoadingIndicator(
                      message: 'Loading your applications...'),
                )
              else if (appVM.state == ViewState.error)
                SliverFillRemaining(
                  child: AppErrorWidget(
                    message: appVM.errorMessage ?? 'Failed to load',
                    onRetry: _loadData,
                  ),
                )
              else if (appVM.applications.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(
                    title: 'No Applications Yet',
                    subtitle:
                        'You have not submitted any Student Assistant applications. Tap the button above to apply.',
                    icon: Icons.assignment_outlined,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _ApplicationCard(
                          application: appVM.applications[i]),
                    ),
                    childCount: appVM.applications.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplySection(ApplicationViewModel appVM) {
    if (appVM.hasExistingApplication) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withOpacity(0.08),
              AppColors.accent.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline_rounded,
                  color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You have already submitted an application. Only one application is allowed.',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ApplicationFormScreen()),
            );
            _loadData();
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Apply for Student Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ApplicationDetailScreen(applicationId: application.id),
        ),
      ).then((_) {
        final auth = context.read<AuthViewModel>();
        context
            .read<ApplicationViewModel>()
            .loadStudentData(auth.profile!.id);
      }),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                border:
                    Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_outlined,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      application.module1?.displayName ?? 'Application',
                      style: AppTextStyles.heading3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: application.status),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (application.module2 != null) ...[
                    _infoChip(Icons.book_outlined,
                        application.module2!.displayName),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      _infoChip(Icons.calendar_today_outlined,
                          'Year ${application.yearOfStudy}'),
                      const SizedBox(width: 12),
                      _infoChip(
                          Icons.access_time_rounded,
                          DateFormat('dd MMM yyyy')
                              .format(application.createdAt)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(label,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12)),
      ],
    );
  }
}