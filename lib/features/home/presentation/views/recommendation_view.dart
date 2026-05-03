import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import '../widgets/doctor_list_tile.dart';
import '../widgets/recommendation_widgets.dart';
import '../widgets/shared_app_bar.dart';

class RecommendationView extends StatefulWidget {
  const RecommendationView({super.key, this.filterSpeciality});
  final String? filterSpeciality;

  @override
  State<RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<RecommendationView> {
  String _searchQuery = '';

  List<DoctorModel> get _filtered => HomeStaticData.recommendedDoctors
      .where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  void _showSortSheet() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SortBottomSheet(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: SharedAppBar(
        title: 'Recommendations',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          RecommendationSearchRow(
            onChanged: (v) => setState(() => _searchQuery = v),
            onFilterTap: _showSortSheet,
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => DoctorListTile(
                doctor: _filtered[index],
                onTap: () => context.pushNamed(
                  Routes.doctorDetailsView,
                  extra: _filtered[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
