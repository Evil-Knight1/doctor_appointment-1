import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart' show Assets;
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/available_doctors_section.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/banner_widget.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/doctor_specialties_section.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/popular_doctors_section.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final DoctorsCubit _doctorsCubit;

  @override
  void initState() {
    super.initState();
    _doctorsCubit = getIt<DoctorsCubit>();
    _doctorsCubit.fetchDoctors(pageNumber: 1, pageSize: 10);
  }

  @override
  void dispose() {
    _doctorsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorsCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildHeader(),
                SizedBox(height: 16.h),
                const SearchBarWidget(),
                SizedBox(height: 20.h),
                const BannerWidget(),
                SizedBox(height: 24.h),
                const DoctorSpecialtiesSection(),
                SizedBox(height: 24.h),
                const PopularDoctorsSection(),
                SizedBox(height: 24.h),
                const AvailableDoctorsSection(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, Laith Mahdi', style: AppStyles.styleSemiBold22),
            SizedBox(height: 2.h),
            Text(
              'Good Morning',
              style: AppStyles.styleRegular14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          height: 50.h,
          width: 50.w,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: SvgPicture.asset(Assets.imagesNotificationIcon),
        ),
      ],
    );
  }
}
