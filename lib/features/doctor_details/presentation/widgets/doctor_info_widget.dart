import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorInfoWidget extends StatelessWidget {
  final HomeDoctorModel doctor;
  const DoctorInfoWidget({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.name,
                style: context.styleSemiBold22.copyWith(fontSize: 18.sp),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  doctor.specialty,
                  style: context.styleRegular12.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            doctor.fee,
            style: context.styleSemiBold22.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}
