import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart' as home_models;
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'doctor_card.dart';
import 'section_header.dart';

extension DoctorToHomeModel on Doctor {
  home_models.DoctorModel toHomeModel() {
    return home_models.DoctorModel(
      id: id.toString(),
      name: fullName,
      speciality: specialization ?? 'General',
      hospital: hospital ?? 'Unknown Hospital',
      rating: averageRating ?? 0.0,
      reviewCount: totalReviews,
      avatarAsset: 'assets/images/doctor1.png',
      isAvailable: isApproved,
    );
  }
}

class RecommendedDoctorsList extends StatelessWidget {
  const RecommendedDoctorsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recommendation Doctor',
          onSeeAllTap: () => context.pushNamed(Routes.recommendationView),
        ),
        SizedBox(height: AppSpacing.md),
        BlocBuilder<DoctorsCubit, DoctorsState>(
          builder: (context, state) {
            if (state is DoctorsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorsFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is DoctorsSuccess) {
              final doctors = state.page.items;
              if (doctors.isEmpty) {
                return const Center(child: Text('No recommended doctors found.'));
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctors.length > 5 ? 5 : doctors.length, // Limit to 5 for home
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) {
                  final doctor = doctors[index];
                  return DoctorCard(doctor: doctor.toHomeModel());
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
