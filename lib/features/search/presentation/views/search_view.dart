import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/doctor_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_state.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  // Global static notifier to pass search query from other screens (e.g. Home)
  static final ValueNotifier<String?> pendingSearchQuery = ValueNotifier<String?>(null);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final DoctorsCubit _doctorsCubit;
  late final SpecializationsCubit _specializationsCubit;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchTerm = '';
  int? _selectedSpecializationId;

  @override
  void initState() {
    super.initState();
    _doctorsCubit = getIt<DoctorsCubit>();
    _specializationsCubit = getIt<SpecializationsCubit>();
    
    // Listen to pending search query
    SearchView.pendingSearchQuery.addListener(_handlePendingSearch);
    
    // Check if there is an initial pending query
    if (SearchView.pendingSearchQuery.value != null) {
      _searchTerm = SearchView.pendingSearchQuery.value!;
      _searchController.text = _searchTerm;
      SearchView.pendingSearchQuery.value = null; // Consume it
    }

    // Load data
    _doctorsCubit.fetchDoctors(
      pageNumber: 1, 
      pageSize: 10,
      searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
    );
    if (_specializationsCubit.state is! SpecializationsSuccess) {
      _specializationsCubit.fetchSpecializations();
    }
    
    _scrollController.addListener(_onScroll);
  }

  void _handlePendingSearch() {
    if (SearchView.pendingSearchQuery.value != null && mounted) {
      setState(() {
        _searchTerm = SearchView.pendingSearchQuery.value!;
        _searchController.text = _searchTerm;
        _selectedSpecializationId = null; // Clear specialization filter when searching from Home
      });
      SearchView.pendingSearchQuery.value = null; // Consume it
      _search();
    }
  }

  @override
  void dispose() {
    SearchView.pendingSearchQuery.removeListener(_handlePendingSearch);
    _searchController.dispose();
    _scrollController.dispose();
    _doctorsCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _doctorsCubit.fetchNextPage(
        specializationId: _selectedSpecializationId,
        searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      );
    }
  }

  void _search() {
    _searchTerm = _searchController.text.trim();
    _doctorsCubit.fetchDoctors(
      specializationId: _selectedSpecializationId,
      searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      pageNumber: 1,
      pageSize: 10,
    );
  }

  void _selectSpecialty(int? specializationId) {
    setState(() {
      _selectedSpecializationId = specializationId;
    });
    _doctorsCubit.fetchDoctors(
      specializationId: _selectedSpecializationId,
      searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      pageNumber: 1,
      pageSize: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _doctorsCubit),
        BlocProvider.value(value: _specializationsCubit),
      ],
      child: Scaffold(
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
        style: context.styleSemiBold22.copyWith(fontSize: 20.sp),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: 'Search by name or specialty...',
            hintStyle: context.styleRegular14.copyWith(
              color: colorScheme.outline,
              fontSize: 13.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.outline,
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
                    color: colorScheme.outline,
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
    return BlocBuilder<SpecializationsCubit, SpecializationsState>(
      builder: (context, state) {
        if (state is! SpecializationsSuccess) {
          return const SizedBox.shrink();
        }

        final specs = state.specializations;
        return SizedBox(
          height: 36.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: specs.length + 1,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (_, index) {
              final bool isAll = index == 0;
              final String name = isAll ? 'All' : specs[index - 1].name;
              final int? id = isAll ? null : specs[index - 1].id;
              final isSelected = id == _selectedSpecializationId;

              return GestureDetector(
                onTap: () => _selectSpecialty(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    name,
                    style: context.styleRegular12.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary 
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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
            style: context.styleRegular12.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
              itemCount: 6,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (_, index) => DoctorListTile(
                doctor: HomeDoctorModel(
                  doctor: Doctor(
                    id: 0,
                    fullName: 'Doctor Full Name',
                    email: '',
                    phone: '',
                    specializationId: 0,
                    specialization: const Specialization(id: 0, name: 'Specialization'),
                    isApproved: true,
                    totalReviews: 0,
                    createdAt: DateTime.now(),
                    isAvailable: true,
                    hospital: 'Hospital Name',
                  ),
                ),
                onTap: () {},
              ),
            ),
          );
        }
        if (state is DoctorsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 48.sp,
                  color: Theme.of(context).colorScheme.outline,
                ),
                SizedBox(height: 12.h),
                Text(
                  state.message,
                  style: context.styleRegular14.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            return Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 56.sp,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No doctors found',
                      style: context.styleSemiBold22.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Try a different search or specialty',
                      style: context.styleRegular14.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
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
                final doctorModel = doctors[index];
                return DoctorListTile(
                  doctor: doctorModel,
                  onTap: () => context.pushNamed(
                    Routes.doctorDetailsView,
                    extra: doctorModel,
                  ),
                );
              }
              return Skeletonizer(
                enabled: true,
                child: DoctorListTile(
                  doctor: HomeDoctorModel(
                    doctor: Doctor(
                      id: 0,
                      fullName: 'Doctor Full Name',
                      email: '',
                      phone: '',
                      specializationId: 0,
                      specialization: const Specialization(id: 0, name: 'Specialization'),
                      isApproved: true,
                      totalReviews: 0,
                      createdAt: DateTime.now(),
                      isAvailable: true,
                      hospital: 'Hospital Name',
                    ),
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

List<HomeDoctorModel> _mapDoctors(List<Doctor> doctors) {
  return doctors.map((doctor) => HomeDoctorModel(doctor: doctor)).toList();
}
