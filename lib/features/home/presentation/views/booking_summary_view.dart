import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/features/payments/logic/payment_cubit.dart';
import 'package:doctor_appointment/features/payments/logic/payment_state.dart';
import 'package:doctor_appointment/features/payments/presentation/views/payment_webview_screen.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:doctor_appointment/core/utils/result.dart';

import 'package:doctor_appointment/core/utils/go_router.dart' show AppRouter;
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import '../widgets/booking_stepper.dart';
import '../widgets/shared_app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

class BookingSummaryView extends StatefulWidget {
  const BookingSummaryView({super.key, required this.args});
  final Map<String, dynamic> args;

  @override
  State<BookingSummaryView> createState() => _BookingSummaryViewState();
}

class _BookingSummaryViewState extends State<BookingSummaryView> {
  bool _isRescheduling = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Doctor doctor = widget.args['doctor'];
    final String time = widget.args['time'] ?? '';
    final int paymentMethodId = widget.args['paymentMethod'] as int? ?? 3;
    final String paymentLabel =
        widget.args['paymentLabel'] as String? ?? 'Cash at Clinic';
    final int slotId = widget.args['slotId'] as int? ?? 0;
    final String reason = widget.args['reason'] as String? ?? '';
    final double amount =
        widget.args['amount'] as double? ?? doctor.consultationPrice ?? 0.0;
    final int appointmentType = widget.args['type'] as int? ?? 0;

    final int? rescheduleAppointmentId =
        widget.args['rescheduleAppointmentId'] as int?;
    final bool isReschedule = rescheduleAppointmentId != null;

    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSessionCreated) {
          // Open Paymob in-app WebView — no browser redirect.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PaymentWebViewScreen(
                paymentUrl: state.session.paymentUrl,
                cubit: context.read<PaymentCubit>(),
              ),
            ),
          );
        } else if (state is PaymentPendingVerification) {
          // Navigate to polling/status screen.
          context.push(
            AppRouter.kPaymentStatusView,
            extra: {
              'cubit': context.read<PaymentCubit>(),
              'appointmentId': state.appointmentId,
              'amount': state.amount,
              'currency': state.currency,
            },
          );
        } else if (state is PaymentSuccess || state is PaymentCashConfirmed) {
          context.goNamed(Routes.bookingConfirmedView, extra: widget.args);
        } else if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is PaymentCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.paymentCancelled),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PaymentLoading;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: SharedAppBar(title: AppLocalizations.of(context)!.reviewSummary),
          body: Column(
            children: [
              const BookingStepper(currentStep: 2),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _SectionCard(
                      title: AppLocalizations.of(context)!.doctorInformation,
                      child: Row(
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child:
                                doctor.profilePictureUrl != null &&
                                    doctor.profilePictureUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: ImageUrlHelper.getFullUrl(
                                      doctor.profilePictureUrl,
                                    ),
                                    httpHeaders:
                                        ImageUrlHelper.getImageHeaders(),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Skeletonizer(
                                      enabled: true,
                                      child: Container(
                                        width: 60.w,
                                        height: 60.h,
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person_rounded,
                                      color: colorScheme.primary,
                                      size: 30.sp,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    color: colorScheme.primary,
                                    size: 30.sp,
                                  ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.fullName,
                                  style: context.headingSmall,
                                ),
                                Text(
                                  '${doctor.specialization.name} | ${doctor.hospital ?? AppLocalizations.of(context)!.clinic}',
                                  style: context.bodySmall.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _SectionCard(
                      title: AppLocalizations.of(context)!.appointmentDetails,
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.access_time,
                            label: AppLocalizations.of(context)!.timeSlot,
                            value: time,
                          ),
                          Divider(
                            height: 24.h,
                            color: colorScheme.outlineVariant,
                          ),
                          _DetailRow(
                            icon: Icons.medical_services_outlined,
                            label: AppLocalizations.of(context)!.appointmentType,
                            value: appointmentType == 1
                                ? AppLocalizations.of(context)!.consultation
                                : AppLocalizations.of(context)!.regularVisit,
                          ),
                          if (reason.isNotEmpty) ...[
                            Divider(
                              height: 24.h,
                              color: colorScheme.outlineVariant,
                            ),
                            _DetailRow(
                              icon: Icons.description_outlined,
                              label: AppLocalizations.of(context)!.reason,
                              value: reason,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isReschedule) ...[
                      SizedBox(height: AppSpacing.lg),
                      _SectionCard(
                        title: AppLocalizations.of(context)!.paymentMethod,
                        child: _DetailRow(
                          icon: _iconForMethod(paymentMethodId),
                          label: AppLocalizations.of(context)!.method,
                          value: paymentLabel,
                          trailing: GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              AppLocalizations.of(context)!.change,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      _SectionCard(
                        title: AppLocalizations.of(context)!.costSummary,
                        child: Column(
                          children: [
                            _CostRow(
                              label: AppLocalizations.of(context)!.consultation,
                              value: '${amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.egpSuffix}',
                            ),
                            Divider(
                              height: 24.h,
                              color: colorScheme.outlineVariant,
                            ),
                            _CostRow(
                              label: AppLocalizations.of(context)!.total,
                              value: '${amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.egpSuffix}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      if (paymentMethodId == 3) ...[
                        SizedBox(height: AppSpacing.md),
                        _InfoBanner(
                          message: AppLocalizations.of(context)!.cashAtClinicInfo,
                        ),
                      ] else ...[
                        SizedBox(height: AppSpacing.md),
                        _InfoBanner(
                          message: AppLocalizations.of(context)!.paymobPaymentInfo,
                          isPaymob: true,
                        ),
                      ],
                    ] else ...[
                      SizedBox(height: AppSpacing.lg),
                      _InfoBanner(
                        message: AppLocalizations.of(context)!.rescheduleNoPayment,
                      ),
                    ],
                  ],
                ),
              ),
              _BottomAction(
                isLoading: isLoading || _isRescheduling,
                isCash: paymentMethodId == 3 || isReschedule,
                onConfirm: () async {
                  if (isReschedule) {
                    setState(() => _isRescheduling = true);
                    final result = await context
                        .read<AppointmentsCubit>()
                        .selectRescheduleSlot(rescheduleAppointmentId!, slotId);
                    if (mounted) {
                      setState(() => _isRescheduling = false);
                      if (result is Success) {
                        context.goNamed(
                          Routes.bookingConfirmedView,
                          extra: widget.args,
                        );
                      } else if (result is FailureResult) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              (result as FailureResult).failure.message,
                            ),
                            backgroundColor: colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  } else {
                    final int doctorId = doctor.id;
                    context.read<PaymentCubit>().checkout(
                      context: context,
                      doctorId: doctorId,
                      slotId: slotId,
                      reason: reason.isEmpty ? AppLocalizations.of(context)!.generalConsultation : reason,
                      paymentMethod: paymentMethodId,
                      amount: amount,
                      type: appointmentType,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForMethod(int id) {
    switch (id) {
      case 4:
        return Icons.credit_card_rounded;
      case 5:
        return Icons.phone_android_rounded;
      case 3:
      default:
        return Icons.payments_outlined;
    }
  }
}

// ─── Info Banner ──────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message, this.isPaymob = false});
  final String message;
  final bool isPaymob;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isPaymob
            ? colorScheme.primary.withValues(alpha: 0.1)
            : customColors.warning?.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isPaymob
              ? colorScheme.primary.withValues(alpha: 0.3)
              : customColors.warning!.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPaymob ? Icons.lock_outline : Icons.info_outline,
            size: 16.sp,
            color: isPaymob ? colorScheme.primary : customColors.warning,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: context.bodySmall.copyWith(
                fontSize: 11.5.sp,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.headingSmall),
          SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18.sp, color: colorScheme.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.bodySmall.copyWith(
                  fontSize: 10.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

// ─── Cost Row ─────────────────────────────────────────────────────────────────

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });
  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal ? context.headingSmall : context.bodyMedium).copyWith(
            color: isTotal
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: isTotal
              ? context.headingSmall.copyWith(color: colorScheme.primary)
              : context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
        ),
      ],
    );
  }
}

// ─── Bottom Action Bar ────────────────────────────────────────────────────────

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.onConfirm,
    required this.isLoading,
    required this.isCash,
  });
  final VoidCallback onConfirm;
  final bool isLoading;
  final bool isCash;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  isCash ? AppLocalizations.of(context)!.bookAppointment : AppLocalizations.of(context)!.confirmAndPay,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
        ),
      ),
    );
  }
}
