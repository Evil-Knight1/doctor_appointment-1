import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/favorite/presentation/widgets/favorite_doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  final List<DoctorModel> _favorites = [
    DoctorModel(
      id: 1,
      name: 'Dr. Ayesha Rahman',
      specialty: 'Dentist',
      rating: 5.0,
      reviews: 200,
      fee: '\$15/hr',
      imageAsset: Assets.imagesDrAyeshaRahman,
      isFavorite: true,
    ),
    DoctorModel(
      id: 2,
      name: 'Dr. Noble Thorme',
      specialty: 'Ophthalmologist',
      rating: 4.8,
      reviews: 180,
      fee: '\$18/hr',
      imageAsset: Assets.imagesDrNobleThorme,
      isFavorite: true,
    ),
    DoctorModel(
      id: 3,
      name: 'Dr. Sarah',
      specialty: 'ENT Specialist',
      rating: 4.9,
      reviews: 150,
      fee: '\$20/hr',
      imageAsset: Assets.imagesDrSarah,
      isFavorite: true,
    ),
  ];

  void _removeFromFavorites(int index) {
    setState(() => _favorites.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Favorites',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: _favorites.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: _favorites.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (_, index) => FavoriteDoctorCard(
                doctor: _favorites[index],
                onRemove: () => _removeFromFavorites(index),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 70.sp,
            color: AppColors.border,
          ),
          SizedBox(height: 16.h),
          Text(
            'No favorites yet',
            style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Doctors you favorite will\nappear here',
            textAlign: TextAlign.center,
            style: AppStyles.styleRegular14.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
