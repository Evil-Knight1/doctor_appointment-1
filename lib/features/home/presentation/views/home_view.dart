<<<<<<< HEAD
=======
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart' show Assets;
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/available_doctors_section.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/banner_widget.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/doctor_specialties_section.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/popular_doctors_section.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
>>>>>>> cb87b61b43edfb00699fa14b417cb11501eb9004
import 'package:flutter/material.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recommended_doctors_list.dart';
import '../widgets/specialities_list.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const HomeAppBar(),
      body: const _HomeBody(),
    );
  }
}

<<<<<<< HEAD
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sm),
              const HomeHeader(userName: 'Omar'),
              SizedBox(height: AppSpacing.xl),
              const HomeSearchBar(),
              SizedBox(height: AppSpacing.xl),
              const QuickAccessGrid(),
              SizedBox(height: AppSpacing.xxl),
              const SpecialitiesList(),
              SizedBox(height: AppSpacing.xxl),
              const RecommendedDoctorsList(),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }
=======
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.kChatHistoryView),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            bottom: 100.h, // prevents content from hiding under curved nav bar
          ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: AppStyles.styleSemiBold22.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Cairo, Egypt', // Placeholder or real location if available
                    style: AppStyles.styleRegular14.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              height: 48.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  Assets.imagesNotificationIcon,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12.w,
              top: 12.h,
              child: Container(
                height: 8.h,
                width: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

>>>>>>> cb87b61b43edfb00699fa14b417cb11501eb9004
}
