import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'doctor_card.dart';
import 'section_header.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

extension DoctorToHomeModel on Doctor {
  HomeDoctorModel toHomeModel() {
    return HomeDoctorModel(doctor: this);
  }
}

class RecommendedDoctorsList extends StatelessWidget {
  const RecommendedDoctorsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.recommendedDoctors,
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
                return Center(
                  child: Text(
                    l10n.seeAll,
                  ), // Or add a specific "No doctors" key
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctors.length > 5
                    ? 5
                    : doctors.length, // Limit to 5 for home
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
