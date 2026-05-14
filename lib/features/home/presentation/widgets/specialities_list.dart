import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/specialty_mapper.dart';
import 'section_header.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_state.dart';

import 'package:doctor_appointment/l10n/app_localizations.dart';

class SpecialitiesList extends StatelessWidget {
  const SpecialitiesList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.specialties,
          onSeeAllTap: () => context.pushNamed(Routes.doctorSpecialityView),
        ),
        SizedBox(height: AppSpacing.md),
        BlocBuilder<SpecializationsCubit, SpecializationsState>(
          builder: (context, state) {
            if (state is SpecializationsLoading) {
              return Skeletonizer(
                enabled: true,
                child: SizedBox(
                  height: 92.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: 5,
                    separatorBuilder: (_, _) => SizedBox(width: AppSpacing.md),
                    itemBuilder: (_, index) {
                      return const SpecialityCard(
                        speciality: SpecialityModel(
                          name: 'Loading...',
                          icon: Icons.medical_services,
                          color: Colors.grey,
                          bgColor: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              );
            } else if (state is SpecializationsSuccess) {
              final uniqueNames = state.uniqueNames.toList();
              return SizedBox(
                height: 92.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: uniqueNames.length,
                  separatorBuilder: (_, _) => SizedBox(width: AppSpacing.md),
                  itemBuilder: (_, index) {
                    final name = uniqueNames[index];
                    final spec = state.specializations.firstWhere(
                      (s) => s.name == name,
                    );
                    final theme = SpecialtyMapper.getThemeForSpecialty(
                      spec.name,
                      Theme.of(context).colorScheme,
                    );
                    final model = SpecialityModel(
                      name: spec.name,
                      icon: theme.icon,
                      color: theme.color,
                      bgColor: theme.bgColor,
                    );
                    return SpecialityCard(speciality: model);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class SpecialityCard extends StatelessWidget {
  const SpecialityCard({super.key, required this.speciality});

  final SpecialityModel speciality;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () =>
          context.pushNamed(Routes.recommendationView, extra: speciality.name),
      child: Container(
        width: 76.w,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SpecialityIcon(speciality: speciality),
            SizedBox(height: AppSpacing.sm),
            _SpecialityLabel(name: speciality.name),
          ],
        ),
      ),
    );
  }
}

class _SpecialityIcon extends StatelessWidget {
  const _SpecialityIcon({required this.speciality});

  final SpecialityModel speciality;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: speciality.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(speciality.icon, size: 22.sp, color: speciality.color),
    );
  }
}

class _SpecialityLabel extends StatelessWidget {
  const _SpecialityLabel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: context.bodySmall.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
