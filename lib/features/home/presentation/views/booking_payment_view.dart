import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/booking_payment_widgets.dart';
import '../widgets/booking_stepper.dart';
import '../widgets/shared_app_bar.dart';

class BookingPaymentView extends StatefulWidget {
  const BookingPaymentView({super.key, required this.args});
  final Map<String, dynamic> args;

  @override
  State<BookingPaymentView> createState() => _BookingPaymentViewState();
}

class _BookingPaymentViewState extends State<BookingPaymentView> {
  String _selectedMethod = 'Paypal';

  static const _creditCards = [
    ('Master Card', Icons.credit_card_rounded, Color(0xFFEB5757)),
    ('American Express', Icons.credit_card_rounded, Color(0xFF2D9CDB)),
    ('Capital One', Icons.credit_card_rounded, Color(0xFF6FCF97)),
    ('Barclays', Icons.credit_card_rounded, Color(0xFFF2994A)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const SharedAppBar(title: 'Book Appointment'),
      body: Column(
        children: [
          const BookingStepper(currentStep: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Payment Option', style: AppTextStyles.headingLarge),
                SizedBox(height: AppSpacing.lg),
                PaymentOptionGroup(
                  label: 'Credit Card',
                  selected: _selectedMethod,
                  cards: _creditCards,
                  onSelect: (v) => setState(() => _selectedMethod = v),
                ),
                OtherMethodTile(
                  label: 'Bank Transfer',
                  icon: Icons.account_balance_outlined,
                  selected: _selectedMethod == 'Bank Transfer',
                  onTap: () => setState(() => _selectedMethod = 'Bank Transfer'),
                ),
                OtherMethodTile(
                  label: 'Paypal',
                  icon: Icons.paypal_rounded,
                  selected: _selectedMethod == 'Paypal',
                  onTap: () => setState(() => _selectedMethod = 'Paypal'),
                ),
              ],
            ),
          ),
          ContinueBar(
            onContinue: () => context.pushNamed(
              Routes.bookingSummaryView,
              extra: {...widget.args, 'payment': _selectedMethod},
            ),
          ),
        ],
      ),
    );
  }
}
