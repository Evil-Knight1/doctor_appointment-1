import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/category_doctor_card.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/filter_bottom_sheet.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/sort_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CategoryDetailView extends StatefulWidget {
  final String? categoryName;

  const CategoryDetailView({super.key, this.categoryName});

  @override
  State<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  late final DoctorsCubit _doctorsCubit;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _doctorsCubit = getIt<DoctorsCubit>();
    _doctorsCubit.fetchDoctors(
      specialization: widget.categoryName,
      pageNumber: 1,
      pageSize: 10,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _doctorsCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _doctorsCubit.fetchNextPage(
        specialization: widget.categoryName,
        searchTerm: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
    }
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SortBottomSheet(),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          FilterBottomSheet(categoryName: widget.categoryName ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorsCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildSearchAndFilter(context),
            _buildResultsHeader(context),
            Expanded(child: _buildDoctorsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        if (state is DoctorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DoctorsFailure) {
          return Center(
            child: Text(
              state.message,
              style: AppStyles.styleRegular14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        if (state is DoctorsSuccess || state is DoctorsPaginationLoading) {
          final page = state is DoctorsSuccess ? state.page : (state as DoctorsPaginationLoading).lastPage;
          final doctors = _mapDoctors(page.items);
          final hasNextPage = page.hasNextPage;

          if (doctors.isEmpty) {
            return Center(
              child: Text(
                'No doctors found.',
                style: AppStyles.styleRegular14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            itemCount: doctors.length + (hasNextPage ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, index) {
              if (index < doctors.length) {
                return CategoryDoctorCard(doctor: doctors[index]);
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 16.sp,
          ),
        ),
      ),
      title: Text(
        widget.categoryName ?? '',
        style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Find the right doctor for you...',
                  hintStyle: AppStyles.styleRegular14.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textLight,
                    size: 18.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                ),
                onSubmitted: (value) {
                  _doctorsCubit.fetchDoctors(
                    specialization: widget.categoryName,
                    searchTerm: value.trim().isEmpty ? null : value.trim(),
                    pageNumber: 1,
                    pageSize: 10,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(Assets.imagesFilterIcon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context) {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        final totalCount = state is DoctorsSuccess ? state.page.totalCount : 0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalCount Found for "${widget.categoryName ?? ''}"',
                style: AppStyles.styleRegular14.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              GestureDetector(
                onTap: () => _showSortSheet(context),
                child: Row(
                  children: [
                    Text(
                      'Sort by',
                      style: AppStyles.styleRegular14.copyWith(
                        color: AppColors.primary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.primary,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<DoctorModel> _mapDoctors(List<Doctor> doctors) {
  final images = [
    Assets.imagesDrAyeshaRahman,
    Assets.imagesDrNobleThorme,
    Assets.imagesDrSarah,
  ];

  return doctors.asMap().entries.map((entry) {
    final index = entry.key;
    final doctor = entry.value;
    return DoctorModel(
      id: doctor.id,
      name: doctor.fullName,
      specialty: doctor.specialization ?? 'General',
      rating: doctor.averageRating ?? 0,
      reviews: doctor.totalReviews,
      fee: 'N/A',
      imageAsset: images[index % images.length],
    );
  }).toList();
}
