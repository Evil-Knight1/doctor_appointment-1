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
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DoctorsCubit>().fetchNextPage(minRating: 3.5);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.kChatHistoryView),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
    );
  }

  Widget _buildHeader() {
    String name = 'Guest';
    final userDataString = SharedPreferencesHelper.getUserData();
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        final email = userData['email'] ?? 'email@example.com';
        name =
            userData['fullName'] ??
            userData['name'] ??
            userData['userName'] ??
            email.split('@').first;
      } catch (e) {
        debugPrint('Error: $e');
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $name', style: AppStyles.styleSemiBold22),
            SizedBox(height: 2.h),
            Text(
              _getGreeting(),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
