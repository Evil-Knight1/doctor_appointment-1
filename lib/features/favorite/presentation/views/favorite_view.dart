import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/features/favorite/presentation/widgets/favorite_doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SharedPreferencesHelper.favoritesVersion,
      builder: (context, _, __) {
        final _favorites = SharedPreferencesHelper.getFavoriteDoctors();
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
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, index) => FavoriteDoctorCard(
                doctor: _favorites[index],
                onRemove: () => SharedPreferencesHelper.toggleFavoriteDoctor(_favorites[index]),
              ),
            ),
        );
      },
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
