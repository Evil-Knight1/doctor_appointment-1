import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/date_picker_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/consultation_type_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/available_time_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/consultation_fees_widget.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';
import 'package:doctor_appointment/features/appointment/logic/doctor_slots_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/doctor_slots_state.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late DoctorSlotsCubit _slotsCubit;
  DateTime _selectedDate = DateTime.now();
  String _selectedConsultation = 'Hospital';
  SlotModel? _selectedSlot;

  List<DateTime> get _weekDays {
    final start = DateTime.now();
    return List.generate(14, (i) => start.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    _slotsCubit = getIt<DoctorSlotsCubit>();
    _fetchSlots();
  }

  void _fetchSlots() {
    _slotsCubit.fetchSlots(widget.doctor.id, _selectedDate);
    setState(() {
      _selectedSlot = null; // Reset selection on date change
    });
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
      body: BlocProvider(
        create: (context) => _slotsCubit,
        child: Stack(
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
                    onDateSelected: (d) {
                      setState(() => _selectedDate = d);
                      _fetchSlots();
                    },
                  ),
                  SizedBox(height: 24.h),
                  _sectionTitle('Consultation Type'),
                  SizedBox(height: 12.h),
                  ConsultationTypeWidget(
                    selected: _selectedConsultation,
                    onSelected: (t) =>
                        setState(() => _selectedConsultation = t),
                  ),
                  SizedBox(height: 24.h),
                  _sectionTitle('Available Slots'),
                  SizedBox(height: 12.h),
                  BlocBuilder<DoctorSlotsCubit, DoctorSlotsState>(
                    builder: (context, state) {
                      if (state is DoctorSlotsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is DoctorSlotsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: AppStyles.styleMedium14.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      } else if (state is DoctorSlotsLoaded) {
                        return AvailableTimeWidget(
                          slots: state.slots,
                          selectedSlot: _selectedSlot,
                          onSlotSelected: (s) =>
                              setState(() => _selectedSlot = s),
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
          onPressed: _selectedSlot == null
              ? null
              : () {
                  final draft = AppointmentDraft(
                    doctor: widget.doctor,
                    date: _selectedDate,
                    slot: _selectedSlot!,
                    consultationType: _selectedConsultation,
                  );
                  context.push(AppRouter.kPatientDetails, extra: draft);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.border,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            minimumSize: Size(double.infinity, 52.h),
            elevation: 0,
          ),
          child: Text(
            'Book Appointment',
            style: AppStyles.styleSemiBold16.copyWith(
              color: _selectedSlot == null
                  ? AppColors.textSecondary
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
