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
}
