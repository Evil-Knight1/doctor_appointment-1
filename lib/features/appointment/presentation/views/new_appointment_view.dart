import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/date_picker_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/consultation_type_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/available_slots_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/available_time_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/consultation_fees_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NewAppointmentView extends StatefulWidget {
  final DoctorModel doctor;
  const NewAppointmentView({super.key, required this.doctor});

  @override
  State<NewAppointmentView> createState() => _NewAppointmentViewState();
}

class _NewAppointmentViewState extends State<NewAppointmentView> {
  DateTime _selectedDate = DateTime(2020, 7, 14);
  String _selectedConsultation = 'Hospital';
  String _selectedSlot = 'Morning';
  String _selectedTime = '10:00';

  List<DateTime> get _weekDays {
    final start = DateTime(2020, 7, 13);
    return List.generate(4, (i) => start.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: Text(
          'New Appointment',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                DatePickerWidget(
                  selectedDate: _selectedDate,
                  weekDays: _weekDays,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                ),
                SizedBox(height: 24.h),
                _sectionTitle('Consultation Type'),
                SizedBox(height: 12.h),
                ConsultationTypeWidget(
                  selected: _selectedConsultation,
                  onSelected: (t) => setState(() => _selectedConsultation = t),
                ),
                SizedBox(height: 24.h),
                _sectionTitle('Available Slots'),
                SizedBox(height: 12.h),
                AvailableSlotsWidget(
                  selectedSlot: _selectedSlot,
                  onSlotSelected: (s) => setState(() => _selectedSlot = s),
                ),
                SizedBox(height: 16.h),
                _sectionTitle('Available Time'),
                SizedBox(height: 12.h),
                AvailableTimeWidget(
                  selectedTime: _selectedTime,
                  onTimeSelected: (t) => setState(() => _selectedTime = t),
                ),
                SizedBox(height: 24.h),
                _sectionTitle('Consultation Fees'),
                SizedBox(height: 12.h),
                const ConsultationFeesWidget(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: AppStyles.styleSemiBold22.copyWith(fontSize: 15.sp));

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {
            final draft = AppointmentDraft(
              doctor: widget.doctor,
              date: _selectedDate,
              time: _selectedTime,
              consultationType: _selectedConsultation,
            );
            context.push(AppRouter.kPatientDetails, extra: draft);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            minimumSize: Size(double.infinity, 52.h),
            elevation: 0,
          ),
          child: Text('Book Appointment', style: AppStyles.styleSemiBold16),
        ),
      ),
    );
  }
}
