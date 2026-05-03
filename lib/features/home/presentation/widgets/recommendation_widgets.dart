import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class RecommendationSearchRow extends StatelessWidget {
  const RecommendationSearchRow({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
  });
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow.withValues(alpha: 0.07),
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: AppTextStyles.bodyMedium,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18.sp,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  String _selectedSort = 'Rating';
  String _selectedSpeciality = 'All';
  int _selectedRating = 4;

  static const _sortOptions = ['Rating', 'Experience', 'Price'];
  static const _specialities = [
    'All',
    'General',
    'Cardiology',
    'Neurologic',
    'Pediatric',
    'Dentistry'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 45.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sort & Filter', style: AppTextStyles.displayMedium),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedSort = 'Rating';
                  _selectedSpeciality = 'All';
                  _selectedRating = 4;
                }),
                child: Text(
                  'Reset',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),
          _FilterSection(
            title: 'Sort By',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: _sortOptions
                  .map(
                    (o) => ChipOption(
                      label: o,
                      selected: _selectedSort == o,
                      onTap: () => setState(() => _selectedSort = o),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          _FilterSection(
            title: 'Speciality',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: _specialities
                  .map(
                    (s) => ChipOption(
                      label: s,
                      selected: _selectedSpeciality == s,
                      onTap: () => setState(() => _selectedSpeciality = s),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          _FilterSection(
            title: 'Minimum Rating',
            child: Row(
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _selectedRating = i + 1),
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 32.sp,
                      color: i < _selectedRating
                          ? AppColors.star
                          : AppColors.divider,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingMedium),
        SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class ChipOption extends StatelessWidget {
  const ChipOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
