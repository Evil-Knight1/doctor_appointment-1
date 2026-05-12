import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recommended_doctors_list.dart';
import '../widgets/specialities_list.dart';

import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<SpecializationsCubit>()..fetchSpecializations(),
        ),
        BlocProvider(
          create: (context) =>
              getIt<DoctorsCubit>()
                ..fetchDoctors(pageNumber: 1, pageSize: 10, minRating: 3.5),
        ),
        BlocProvider(create: (context) => getIt<ProfileCubit>()..loadProfile()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: const HomeAppBar(),
        body: const _HomeBody(),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  Future<void> _handleRefresh(BuildContext context) async {
    // Kick off all three refreshes in parallel and wait for the slowest one.
    await Future.wait([
      context.read<SpecializationsCubit>().fetchSpecializations(),
      context.read<DoctorsCubit>().fetchDoctors(
            pageNumber: 1,
            pageSize: 10,
            minRating: 3.5,
          ),
      context.read<ProfileCubit>().loadProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: () => _handleRefresh(context),
      color: AppColors.primary,
      backgroundColor: Colors.white,
      showChildOpacityTransition: false,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.sm),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    String name =
                        SharedPreferencesHelper.getProfileName() ?? 'User';
                    if (state is ProfileSuccess) {
                      name = state.profile.fullName;
                    }
                    return HomeHeader(userName: name);
                  },
                ),
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
      ),
    );
  }
}
