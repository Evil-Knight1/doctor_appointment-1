import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_state.dart';
import 'package:doctor_appointment/core/utils/specialty_mapper.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/speciality_grid_card.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

class DoctorSpecialityView extends StatelessWidget {
  const DoctorSpecialityView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) =>
          getIt<SpecializationsCubit>()..fetchSpecializations(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: SharedAppBar(title: AppLocalizations.of(context)!.specialties),
        body: BlocBuilder<SpecializationsCubit, SpecializationsState>(
          builder: (context, state) {
            if (state is SpecializationsLoading) {
              return Skeletonizer(
                enabled: true,
                child: GridView.builder(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return SpecialityGridCard(
                      speciality: SpecialityModel(
                        name: 'Loading...',
                        icon: Icons.medical_services,
                        color: Colors.grey,
                        bgColor: Colors.grey,
                      ),
                      onTap: () {},
                    );
                  },
                ),
              );
            } else if (state is SpecializationsFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is SpecializationsSuccess) {
              final specialities = state.specializations;
              if (specialities.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.noSpecialitiesFound));
              }
              return GridView.builder(
                padding: EdgeInsets.all(AppSpacing.lg),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1,
                ),
                itemCount: specialities.length,
                itemBuilder: (context, index) {
                  final spec = specialities[index];
                  final theme = SpecialtyMapper.getThemeForSpecialty(spec.name, colorScheme);
                  // Map API entity to SpecialityModel for UI
                  final model = SpecialityModel(
                    name: spec.name,
                    icon: theme.icon,
                    color: theme.color,
                    bgColor: theme.bgColor,
                    specializationId: spec.id,
                  );
                  return SpecialityGridCard(
                    speciality: model,
                    onTap: () => context.pushNamed(
                      Routes.recommendationView,
                      extra: spec.id,
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
