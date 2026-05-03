import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'doctor_card.dart';
import 'section_header.dart';

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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: HomeStaticData.recommendedDoctors.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, index) =>
              DoctorCard(doctor: HomeStaticData.recommendedDoctors[index]),
        ),
      ],
    );
  }
}
