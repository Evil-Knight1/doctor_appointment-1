import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/speciality_grid_card.dart';

const _allSpecialities = [
  ...HomeStaticData.specialities,
  SpecialityModel(
    name: 'ENT',
    icon: Icons.hearing_outlined,
    color: Color(0xFF0891B2),
    bgColor: Color(0xFFECFEFF),
  ),
  SpecialityModel(
    name: 'Urologist',
    icon: Icons.water_drop_outlined,
    color: Color(0xFF2563EB),
    bgColor: Color(0xFFEFF6FF),
  ),
  SpecialityModel(
    name: 'Dentistry',
    icon: Icons.masks_outlined,
    color: Color(0xFF059669),
    bgColor: Color(0xFFECFDF5),
  ),
  SpecialityModel(
    name: 'Intestine',
    icon: Icons.biotech_outlined,
    color: Color(0xFF7C3AED),
    bgColor: Color(0xFFF5F3FF),
  ),
  SpecialityModel(
    name: 'Histologist',
    icon: Icons.science_outlined,
    color: Color(0xFFEC4899),
    bgColor: Color(0xFFFDF2F8),
  ),
  SpecialityModel(
    name: 'Hepatology',
    icon: Icons.favorite_outlined,
    color: Color(0xFFDC2626),
    bgColor: Color(0xFFFEF2F2),
  ),
  SpecialityModel(
    name: 'Cardiologist',
    icon: Icons.monitor_heart_outlined,
    color: Color(0xFF0891B2),
    bgColor: Color(0xFFECFEFF),
  ),
  SpecialityModel(
    name: 'Neurologic',
    icon: Icons.psychology_outlined,
    color: Color(0xFF7C3AED),
    bgColor: Color(0xFFF5F3FF),
  ),
  SpecialityModel(
    name: 'Pulmonary',
    icon: Icons.air_outlined,
    color: Color(0xFF2563EB),
    bgColor: Color(0xFFEFF6FF),
  ),
  SpecialityModel(
    name: 'Optometry',
    icon: Icons.visibility_outlined,
    color: Color(0xFF059669),
    bgColor: Color(0xFFECFDF5),
  ),
];

class DoctorSpecialityView extends StatelessWidget {
  const DoctorSpecialityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const SharedAppBar(title: 'Doctor Speciality'),
      body: GridView.builder(
        padding: EdgeInsets.all(AppSpacing.lg),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1,
        ),
        itemCount: _allSpecialities.length,
        itemBuilder: (context, index) => SpecialityGridCard(
          speciality: _allSpecialities[index],
          onTap: () => context.pushNamed(
            Routes.recommendationView,
            extra: _allSpecialities[index].name,
          ),
        ),
      ),
    );
  }
}
