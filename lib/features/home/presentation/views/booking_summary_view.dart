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

import 'package:doctor_appointment/core/utils/go_router.dart' show AppRouter;
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import '../widgets/booking_stepper.dart';
import '../widgets/shared_app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BookingSummaryView extends StatelessWidget {
  const BookingSummaryView({super.key, required this.args});
  final Map<String, dynamic> args;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Doctor doctor = args['doctor'];
    final String time = args['time'] ?? '';
    final int paymentMethodId = args['paymentMethod'] as int? ?? 3;
    final String paymentLabel =
        args['paymentLabel'] as String? ?? 'Cash at Clinic';
    final int slotId = args['slotId'] as int? ?? 0;
    final String reason = args['reason'] as String? ?? '';
    final double amount =
        args['amount'] as double? ?? doctor.consultationFee ?? 0.0;

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
          context.goNamed(Routes.bookingConfirmedView, extra: args);
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
            const SnackBar(
              content: Text('Payment cancelled. You can try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PaymentLoading;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: const SharedAppBar(title: 'Review Summary'),
          body: Column(
            children: [
              const BookingStepper(currentStep: 2),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _SectionCard(
                      title: 'Doctor Information',
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
                                  '${doctor.specialization.name} | ${doctor.hospital ?? 'Clinic'}',
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
                      title: 'Appointment Details',
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.access_time,
                            label: 'Time Slot',
                            value: time,
                          ),
                          if (reason.isNotEmpty) ...[
                            Divider(
                              height: 24.h,
                              color: colorScheme.outlineVariant,
                            ),
                            _DetailRow(
                              icon: Icons.description_outlined,
                              label: 'Reason',
                              value: reason,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _SectionCard(
                      title: 'Payment Method',
                      child: _DetailRow(
                        icon: _iconForMethod(paymentMethodId),
                        label: 'Method',
                        value: paymentLabel,
                        trailing: GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Change',
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
                      title: 'Cost Summary',
                      child: Column(
                        children: [
                          _CostRow(
                            label: 'Consultation',
                            value: '${amount.toStringAsFixed(2)} EGP',
                          ),
                          Divider(
                            height: 24.h,
                            color: colorScheme.outlineVariant,
                          ),
                          _CostRow(
                            label: 'Total',
                            value: '${amount.toStringAsFixed(2)} EGP',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    if (paymentMethodId == 3) ...[
                      SizedBox(height: AppSpacing.md),
                      _InfoBanner(
                        message:
                            'You selected Cash at Clinic. Your appointment will be booked and payment confirmed by the doctor when you arrive.',
                      ),
                    ] else ...[
                      SizedBox(height: AppSpacing.md),
                      _InfoBanner(
                        message:
                            'You will complete payment securely inside the app via Paymob. No browser redirect.',
                        isPaymob: true,
                      ),
                    ],
                  ],
                ),
              ),
              _BottomAction(
                isLoading: isLoading,
                isCash: paymentMethodId == 3,
                onConfirm: () {
                  final int doctorId = doctor.id;
                  context.read<PaymentCubit>().checkout(
                    doctorId: doctorId,
                    slotId: slotId,
                    reason: reason.isEmpty ? 'General Consultation' : reason,
                    paymentMethod: paymentMethodId,
                    amount: amount,
                  );
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
                  isCash ? 'Book Appointment' : 'Confirm & Pay',
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
