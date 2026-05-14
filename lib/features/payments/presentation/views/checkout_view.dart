import 'package:url_launcher/url_launcher.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:doctor_appointment/features/payments/logic/payment_cubit.dart';
import 'package:doctor_appointment/features/payments/logic/payment_state.dart';
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
  int _selectedMethod = 4; // 4 = OnlineCard, 5 = MobileWallet, 3 = CashAtClinic
  late final PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _paymentCubit = getIt<PaymentCubit>();
  }

  @override
  void dispose() {
    _paymentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Assuming a flat fee for consultation for now. You could pull this from doctor's fee.
    final String doctorFeeStr = widget.payload.draft.doctor.fee.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
    final double amount = double.tryParse(doctorFeeStr) ?? 15.0;

    return BlocProvider.value(
      value: _paymentCubit,
      child: Scaffold(
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
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Payment',
            style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Payment Method', style: AppStyles.styleSemiBold16),
              SizedBox(height: 16.h),
              _buildPaymentMethod(
                4,
                'Credit/Debit Card',
                Icons.credit_card_rounded,
              ),
              SizedBox(height: 12.h),
              _buildPaymentMethod(
                5,
                'Mobile Wallet',
                Icons.account_balance_wallet_rounded,
              ),
              SizedBox(height: 12.h),
              _buildPaymentMethod(3, 'Cash at Clinic', Icons.money_rounded),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Fees:',
                    style: AppStyles.styleMedium14.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: AppStyles.styleSemiBold24.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              BlocConsumer<PaymentCubit, PaymentState>(
                listener: (context, state) {
                  if (state is PaymentError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is PaymentSuccess) {
                    context.pushReplacement(AppRouter.kAppointmentSuccess);
                  } else if (state is PaymentRequiresAction) {
                    final uri = Uri.parse(state.paymentUrl);
                    final router = GoRouter.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    launchUrl(uri, mode: LaunchMode.externalApplication)
                        .then((_) {
                          router.pushReplacement(AppRouter.kAppointmentSuccess);
                        })
                        .catchError((_) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Could not open payment gateway'),
                            ),
                          );
                        });
                  }
                },
                builder: (context, state) {
                  final isLoading = state is PaymentProcessing;
                  return CustomButton(
                    text: isLoading ? 'Processing...' : 'Confirm Payment',
                    onPressed: isLoading
                        ? () {}
                        : () {
                            _paymentCubit.checkout(
                              doctorId: widget.payload.draft.doctor.doctor.id,
                              slotId: widget.payload.draft.slot.id,
                              reason: widget.payload.reason,
                              paymentMethod: _selectedMethod,
                              amount: amount,
                            );
                          },
                    width: double.infinity,
                    height: 50.h,
                    circleSize: 12.r,
                    textStyle: AppStyles.styleSemiBold16,
                    buttonColor: isLoading
                        ? Theme.of(context).colorScheme.outlineVariant
                        : Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(int methodValue, String label, IconData icon) {
    final isSelected = _selectedMethod == methodValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = methodValue),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 28.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: AppStyles.styleMedium14.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Theme.of(context).colorScheme.outlineVariant,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
