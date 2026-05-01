import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/category_doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final DoctorsCubit _doctorsCubit;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchTerm = '';

  // Specialty chips
  static const List<String> _specialties = [
    'All',
    'Dentist',
    'Ophthalmologist',
    'ENT Specialist',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Pediatrics',
    'Orthopedics',
  ];
  String _selectedSpecialty = 'All';

  @override
  void initState() {
    super.initState();
    _doctorsCubit = getIt<DoctorsCubit>();
    // Load all doctors initially
    _doctorsCubit.fetchDoctors(pageNumber: 1, pageSize: 10);
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
        specialization:
            _selectedSpecialty == 'All' ? null : _selectedSpecialty,
        searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      );
    }
  }

  void _search() {
    _searchTerm = _searchController.text.trim();
    _doctorsCubit.fetchDoctors(
      specialization: _selectedSpecialty == 'All' ? null : _selectedSpecialty,
      searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      pageNumber: 1,
      pageSize: 10,
    );
  }

  void _selectSpecialty(String specialty) {
    setState(() {
      _selectedSpecialty = specialty;
    });
    _doctorsCubit.fetchDoctors(
      specialization: specialty == 'All' ? null : specialty,
      searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      pageNumber: 1,
      pageSize: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorsCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              SizedBox(height: 12.h),
              _buildSpecialtyChips(),
              SizedBox(height: 8.h),
              _buildResultsCount(),
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Text(
        'Find a Doctor',
        style: AppStyles.styleSemiBold22.copyWith(fontSize: 20.sp),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: 'Search by name or specialty...',
            hintStyle: AppStyles.styleRegular14.copyWith(
              color: AppColors.textLight,
              fontSize: 13.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textLight,
              size: 20.sp,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (_, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchTerm = '');
                    _search();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textLight,
                    size: 18.sp,
                  ),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyChips() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: _specialties.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, index) {
          final specialty = _specialties[index];
          final isSelected = specialty == _selectedSpecialty;
          return GestureDetector(
            onTap: () => _selectSpecialty(specialty),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.bg,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                specialty,
                style: AppStyles.styleRegular12.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsCount() {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        if (state is! DoctorsSuccess && state is! DoctorsPaginationLoading) {
          return const SizedBox.shrink();
        }
        final page = state is DoctorsSuccess
            ? state.page
            : (state as DoctorsPaginationLoading).lastPage;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
          child: Text(
            '${page.totalCount} results found',
            style: AppStyles.styleRegular12.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        if (state is DoctorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DoctorsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 48.sp,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 12.h),
                Text(
                  state.message,
                  style: AppStyles.styleRegular14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        if (state is DoctorsSuccess || state is DoctorsPaginationLoading) {
          final page = state is DoctorsSuccess
              ? state.page
              : (state as DoctorsPaginationLoading).lastPage;
          final doctors = _mapDoctors(page.items);
          final hasNextPage = page.hasNextPage;

          if (doctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 56.sp,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No doctors found',
                    style: AppStyles.styleSemiBold22.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Try a different search or specialty',
                    style: AppStyles.styleRegular14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
            itemCount: doctors.length + (hasNextPage ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, index) {
              if (index < doctors.length) {
                return CategoryDoctorCard(doctor: doctors[index]);
              }
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          );
        }
        return const SizedBox.shrink();
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
