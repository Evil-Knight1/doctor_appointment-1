import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/payments/domain/entities/payment_status.dart';
import 'package:doctor_appointment/features/payments/logic/payment_cubit.dart';
import 'package:doctor_appointment/features/payments/logic/payment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

/// Shows real-time payment verification status while the backend
/// processes the Paymob webhook.
///
/// The cubit polls GET /api/Payment/status/{appointmentId} every 5 s.
/// This screen listens to those state updates and navigates on terminal states.
class PaymentStatusView extends StatelessWidget {
  final Map<String, dynamic> args;

  const PaymentStatusView({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final cubit = args['cubit'] as PaymentCubit;
    final amount = args['amount'] as double?;
    final currency = (args['currency'] as String?) ?? 'EGP';

    return BlocProvider.value(
      value: cubit,
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            context.pushReplacement(AppRouter.kAppointmentSuccess);
          } else if (state is PaymentFailure &&
              state.lastKnownStatus != PaymentStatus.unknown) {
            // Terminal failure — show snack and pop back to checkout.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) => _buildBody(context, state, amount, currency),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PaymentState state,
    double? amount,
    String currency,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIndicator(context, state),
              SizedBox(height: 32.h),
              Text(
                _titleFor(context, state),
                style: context.styleSemiBold22,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                _subtitleFor(context, state),
                style: context.styleRegular14.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (amount != null) ...[
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.amount,
                        style: context.styleRegular14.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '$currency ${amount.toStringAsFixed(2)}',
                        style: context.styleSemiBold16.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (state is PaymentPendingVerification) ...[
                SizedBox(height: 32.h),
                _PollingDots(pollCount: state.pollCount),
              ],
              if (state is PaymentFailure) ...[
                SizedBox(height: 32.h),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(AppLocalizations.of(context)!.backToCheckoutLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, PaymentState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state is PaymentPendingVerification) {
      return SpinKitRipple(color: colorScheme.primary, size: 80.sp);
    }

    if (state is PaymentSuccess) {
      return Icon(
        Icons.check_circle_rounded,
        color: colorScheme.primary,
        size: 80.sp,
      );
    }

    if (state is PaymentFailure) {
      final isTimeout = state.lastKnownStatus == PaymentStatus.unknown;
      return Icon(
        isTimeout ? Icons.access_time_rounded : Icons.cancel_rounded,
        color: isTimeout ? Colors.orange : colorScheme.error,
        size: 80.sp,
      );
    }

    return SpinKitFadingCircle(color: colorScheme.primary, size: 60.sp);
  }

  String _titleFor(BuildContext context, PaymentState state) {
    if (state is PaymentPendingVerification) return AppLocalizations.of(context)!.verifyingPayment;
    if (state is PaymentSuccess) return AppLocalizations.of(context)!.paymentConfirmed;
    if (state is PaymentFailure) {
      if (state.lastKnownStatus == PaymentStatus.unknown) {
        return AppLocalizations.of(context)!.verificationDelayed;
      }
      return '${AppLocalizations.of(context)!.paymentFailedText} ${state.lastKnownStatus?.name.toUpperCase() ?? ''}';
    }
    return AppLocalizations.of(context)!.processing;
  }

  String _subtitleFor(BuildContext context, PaymentState state) {
    if (state is PaymentPendingVerification) {
      return AppLocalizations.of(context)!.waitingForPaymentConfirmation;
    }
    if (state is PaymentSuccess) {
      return AppLocalizations.of(context)!.appointmentConfirmedInfo;
    }
    if (state is PaymentFailure) {
      return state.message;
    }
    return '';
  }
}

/// Animated dots that show polling progress.
class _PollingDots extends StatelessWidget {
  final int pollCount;

  const _PollingDots({required this.pollCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        12,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: i < pollCount ? 8.w : 6.w,
          height: i < pollCount ? 8.w : 6.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < pollCount
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
