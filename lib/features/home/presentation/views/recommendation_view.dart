import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import '../widgets/doctor_list_tile.dart';
import '../widgets/recommendation_widgets.dart';
import '../widgets/shared_app_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';

import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';

class RecommendationView extends StatefulWidget {
  const RecommendationView({super.key, this.filterSpecializationId});
  final int? filterSpecializationId;

  @override
  State<RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<RecommendationView> {
  @override
  void initState() {
    super.initState();
    // Initial fetch
    context.read<DoctorsCubit>().fetchDoctors(
      specializationId: widget.filterSpecializationId,
    );
  }

  void _onSearchChanged(String query) {
    context.read<DoctorsCubit>().fetchDoctors(searchTerm: query);
  }

  void _showSortSheet() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SortBottomSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: SharedAppBar(
        title: 'Recommendations',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert_rounded,
                color: colorScheme.onSurface,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          RecommendationSearchRow(
            onChanged: _onSearchChanged,
            onFilterTap: _showSortSheet,
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: BlocBuilder<DoctorsCubit, DoctorsState>(
              builder: (context, state) {
                if (state is DoctorsLoading) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: 6,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return DoctorListTile(
                          doctor: HomeDoctorModel(
                            doctor: Doctor(
                              id: 0,
                              fullName: 'Doctor Full Name',
                              email: '',
                              phone: '',
                              specializationId: 0,
                              specialization: Specialization(
                                id: 0,
                                name: 'Specialization',
                              ),
                              isApproved: true,
                              totalReviews: 0,
                              createdAt: DateTime.now(),
                              isAvailable: true,
                              hospital: 'Hospital Name',
                            ),
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  );
                } else if (state is DoctorsFailure) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  );
                } else if (state is DoctorsSuccess) {
                  final doctors = state.page.items;
                  if (doctors.isEmpty) {
                    return Center(
                      child: Text(
                        'No doctors found.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: doctors.length,
                    separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      final homeModel = HomeDoctorModel(doctor: doctor);

                      return DoctorListTile(
                        doctor: homeModel,
                        onTap: () => context.pushNamed(
                          Routes.doctorDetailsView,
                          extra: homeModel,
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

