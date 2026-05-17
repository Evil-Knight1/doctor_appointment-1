import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';

import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:doctor_appointment/features/payments/logic/payment_cubit.dart';
import 'package:doctor_appointment/features/payments/logic/payment_state.dart';
import 'package:doctor_appointment/features/payments/presentation/views/payment_webview_screen.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CheckoutPayload {
  final AppointmentDraft draft;
  final String reason;

  const CheckoutPayload({required this.draft, required this.reason});
}

class CheckoutView extends StatefulWidget {
  final CheckoutPayload payload;

  const CheckoutView({super.key, required this.payload});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  /// 1 = Credit/Debit Card, 2 = Mobile Wallet, 3 = Cash at Clinic
  int _selectedMethod = 1;
  late final PaymentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<PaymentCubit>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final amount = widget.payload.draft.amount;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: _handleStateChange,
        builder: (context, state) {
          final isLoading = state is PaymentLoading;

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20.sp,
                ),
                onPressed: isLoading ? null : () => context.pop(),
              ),
              title: Text(
                'Payment',
                style: context.styleSemiBold22.copyWith(fontSize: 18.sp),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Payment Method',
                    style: context.styleSemiBold16,
                  ),
                  SizedBox(height: 16.h),
                  _buildMethodTile(
                    value: 1,
                    label: 'Credit / Debit Card',
                    icon: Icons.credit_card_rounded,
                    subtitle: 'Visa, Mastercard accepted',
                  ),
                  SizedBox(height: 12.h),
                  _buildMethodTile(
                    value: 2,
                    label: 'Mobile Wallet',
                    icon: Icons.account_balance_wallet_rounded,
                    subtitle: 'Vodafone Cash, Etisalat Cash',
                  ),
                  SizedBox(height: 12.h),
                  _buildMethodTile(
                    value: 3,
                    label: 'Cash at Clinic',
                    icon: Icons.payments_rounded,
                    subtitle: 'Pay directly at the clinic',
                  ),
                  const Spacer(),
                  _buildAmountRow(context, amount),
                  SizedBox(height: 8.h),
                  if (state is PaymentLoading) ...[
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        state.message,
                        style: context.styleRegular12.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  CustomButton(
                    text: isLoading ? 'Processing…' : 'Confirm & Pay',
                    onPressed: isLoading ? () {} : _onConfirm,
                    width: double.infinity,
                    height: 52.h,
                    circleSize: 12.r,
                    textStyle: context.styleSemiBold16.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    buttonColor: isLoading
                        ? Theme.of(context).colorScheme.outlineVariant
                        : Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── State Handler ────────────────────────────────────────────────────────

  void _handleStateChange(BuildContext context, PaymentState state) {
    if (state is PaymentSessionCreated) {
      // Open Paymob WebView in-app — no browser redirect.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: state.session.paymentUrl,
            cubit: _cubit,
          ),
        ),
      );
    } else if (state is PaymentPendingVerification) {
      // Navigate to polling/status screen.
      context.push(
        AppRouter.kPaymentStatusView,
        extra: {
          'cubit': _cubit,
          'appointmentId': state.appointmentId,
          'amount': state.amount,
          'currency': state.currency,
        },
      );
    } else if (state is PaymentCashConfirmed) {
      context.pushReplacement(AppRouter.kAppointmentSuccess);
    } else if (state is PaymentFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (state is PaymentCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment cancelled.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _onConfirm() {
    _cubit.checkout(
      doctorId: widget.payload.draft.doctor.doctor.id,
      slotId: widget.payload.draft.slot.id,
      reason: widget.payload.reason,
      paymentMethod: _selectedMethod,
      amount: widget.payload.draft.amount,
    );
  }

  Widget _buildAmountRow(BuildContext context, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Fees:',
          style: context.styleMedium14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          'EGP ${amount.toStringAsFixed(2)}',
          style: context.styleSemiBold24.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTile({
    required int value,
    required String label,
    required IconData icon,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.06)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.styleMedium14.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: context.styleRegular12.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
