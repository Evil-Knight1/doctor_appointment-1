import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/features/favorite/presentation/widgets/favorite_doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<int>(
      valueListenable: SharedPreferencesHelper.favoritesVersion,
      builder: (context, _, _) {
        final favorites = SharedPreferencesHelper.getFavoriteDoctors();
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Favorites',
              style: AppStyles.styleSemiBold22.copyWith(
                fontSize: 18.sp,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          body: favorites.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  itemCount: favorites.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, index) => FavoriteDoctorCard(
                    doctor: favorites[index],
                    onRemove: () =>
                        SharedPreferencesHelper.toggleFavoriteDoctor(
                          favorites[index],
                        ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 70.sp,
            color: colorScheme.outlineVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'No favorites yet',
            style: AppStyles.styleSemiBold22.copyWith(
              fontSize: 18.sp,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Doctors you favorite will\nappear here',
            textAlign: TextAlign.center,
            style: AppStyles.styleRegular14.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
