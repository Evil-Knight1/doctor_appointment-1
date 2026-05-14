import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import '../widgets/booking_stepper.dart';
import '../widgets/shared_app_bar.dart';

class BookingPaymentView extends StatefulWidget {
  const BookingPaymentView({super.key, required this.args});
  final Map<String, dynamic> args;

  @override
  State<BookingPaymentView> createState() => _BookingPaymentViewState();
}

class _BookingPaymentViewState extends State<BookingPaymentView> {
  // Backend values: 3 = CashAtClinic, 4 = OnlineCard, 5 = MobileWallet
  int _selectedMethodId = 4;

  static const _methods = [
    _PaymentMethod(
      id: 4,
      label: 'Online Card',
      subtitle: 'Pay securely with Visa or MasterCard via Paymob',
      icon: Icons.credit_card_rounded,
      type: _PaymentMethodType.online,
    ),
    _PaymentMethod(
      id: 5,
      label: 'Mobile Wallet',
      subtitle: 'Pay with Vodafone Cash, Orange Money or Etisalat Cash',
      icon: Icons.phone_android_rounded,
      type: _PaymentMethodType.wallet,
    ),
    _PaymentMethod(
      id: 3,
      label: 'Cash at Clinic',
      subtitle: 'Pay in person when you arrive at the clinic',
      icon: Icons.payments_outlined,
      type: _PaymentMethodType.cash,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const SharedAppBar(title: 'Book Appointment'),
      body: Column(
        children: [
          const BookingStepper(currentStep: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Payment Option', style: context.headingLarge),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Select how you\'d like to pay for your appointment',
                  style: context.bodySmall,
                ),
                SizedBox(height: AppSpacing.xl),
                ..._methods.map(
                  (method) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PaymentMethodTile(
                      method: method,
                      isSelected: _selectedMethodId == method.id,
                      onTap: () =>
                          setState(() => _selectedMethodId = method.id),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                // Paymob badge
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Payments secured by Paymob',
                        style: context.bodySmall.copyWith(
                          fontSize: 11.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ContinueBar(
            onContinue: () => context.pushNamed(
              Routes.bookingSummaryView,
              extra: {
                ...widget.args,
                'paymentMethod': _selectedMethodId,
                'paymentLabel': _methods
                    .firstWhere((m) => m.id == _selectedMethodId)
                    .label,
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

enum _PaymentMethodType { online, wallet, cash }

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.type,
  });

  final int id;
  final String label;
  final String subtitle;
  final IconData icon;
  final _PaymentMethodType type;
}

// ─── Tile widget ──────────────────────────────────────────────────────────────

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final _PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  Color _getMethodColor(BuildContext context) {
    final customColors = context.customColors;
    final colorScheme = Theme.of(context).colorScheme;
    switch (method.type) {
      case _PaymentMethodType.online:
        return colorScheme.primary;
      case _PaymentMethodType.wallet:
        return customColors.success ?? Colors.green;
      case _PaymentMethodType.cash:
        return customColors.warning ?? Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final methodColor = _getMethodColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: isSelected 
                    ? colorScheme.primary.withValues(alpha: 0.1) 
                    : methodColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? colorScheme.primary : methodColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    method.subtitle,
                    style: context.bodySmall.copyWith(
                      fontSize: 11.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                  width: 2,
                ),
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: colorScheme.onPrimary, size: 12.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Continue bar ─────────────────────────────────────────────────────────────

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
          ),
          child: Text(
            'Continue',
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
