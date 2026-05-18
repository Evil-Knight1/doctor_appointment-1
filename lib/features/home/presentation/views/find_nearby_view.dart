import 'dart:async';

import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FindNearbyView extends StatefulWidget {
  const FindNearbyView({super.key});

  @override
  State<FindNearbyView> createState() => _FindNearbyViewState();
}

class _FindNearbyViewState extends State<FindNearbyView> {
  static final GeoPoint _cairoFallback = GeoPoint(
    latitude: 30.0444,
    longitude: 31.2357,
  );

  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final Map<int, GeoPoint?> _doctorLocationCache = {};

  GeoPoint? _selectedAreaPoint;
  String _selectedAreaLabel = 'Tap the map to choose an area';
  double _radiusKm = 10;
  bool _isResolvingArea = false;
  bool _isRefreshingNearby = false;
  bool _didSetInitialArea = false;
  List<_NearbyDoctorResult> _nearbyDoctors = const [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: true,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDoctors();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<DoctorsCubit, DoctorsState>(
      listener: (context, state) {
        if (state is DoctorsSuccess) {
          unawaited(_refreshNearbyDoctors(state.page.items));
        } else if (state is DoctorsLoading) {
          setState(() => _isRefreshingNearby = true);
        } else if (state is DoctorsFailure) {
          setState(() => _isRefreshingNearby = false);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: SharedAppBar(
          title: 'Find Nearby',
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: IconButton(
                onPressed: _jumpToCurrentLocation,
                icon: Icon(
                  Icons.my_location_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(child: _buildMap(context)),
            _TopControls(
              searchController: _searchController,
              selectedAreaLabel: _selectedAreaLabel,
              radiusKm: _radiusKm,
              isResolvingArea: _isResolvingArea,
              onSearchSubmitted: (_) => _fetchDoctors(),
              onSearchPressed: _fetchDoctors,
              onRadiusChanged: (value) {
                setState(() => _radiusKm = value);
                final state = context.read<DoctorsCubit>().state;
                if (state is DoctorsSuccess) {
                  unawaited(_refreshNearbyDoctors(state.page.items));
                }
              },
            ),
            _NearbyDoctorsSheet(
              nearbyDoctors: _nearbyDoctors,
              isLoading: _isRefreshingNearby,
              onDoctorTap: (doctor, index) {
                context.pushNamed(
                  Routes.doctorDetailsView,
                  extra: {
                    'doctor': doctor,
                    'heroTag': 'nearby-${doctor.id}-$index',
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OSMFlutter(
      controller: _mapController,
      osmOption: OSMOption(
        userTrackingOption: const UserTrackingOption(
          enableTracking: true,
          unFollowUser: true,
        ),
        zoomOption: const ZoomOption(
          initZoom: 13,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.my_location_rounded,
              color: colorScheme.primary,
              size: 40.sp,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(
              Icons.navigation_rounded,
              color: colorScheme.primary,
              size: 36.sp,
            ),
          ),
        ),
        roadConfiguration: RoadOption(roadColor: colorScheme.primary),
      ),
      onMapIsReady: (isReady) async {
        if (!isReady || _didSetInitialArea) return;
        _didSetInitialArea = true;
        await _setInitialArea();
      },
      onGeoPointClicked: (point) async {
        await _selectArea(point, moveCamera: false);
      },
    );
  }

  Future<void> _fetchDoctors() async {
    await context.read<DoctorsCubit>().fetchDoctors(
      searchTerm: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      pageSize: 50,
    );
  }

  Future<void> _setInitialArea() async {
    try {
      await _mapController.currentLocation();
      final currentPoint = await _mapController.myLocation();
      await _selectArea(currentPoint, moveCamera: false);
    } catch (_) {
      await _selectArea(_cairoFallback, moveCamera: true);
    }
  }

  Future<void> _jumpToCurrentLocation() async {
    try {
      await _mapController.currentLocation();
      final currentPoint = await _mapController.myLocation();
      await _selectArea(currentPoint, moveCamera: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access your current location.'),
        ),
      );
    }
  }

  Future<void> _selectArea(GeoPoint point, {required bool moveCamera}) async {
    final previousPoint = _selectedAreaPoint;
    setState(() {
      _selectedAreaPoint = point;
      _isResolvingArea = true;
    });

    try {
      if (previousPoint != null) {
        await _mapController.removeMarkers([previousPoint]);
      }
      await _mapController.addMarker(
        point,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_pin,
            color: Theme.of(context).colorScheme.error,
            size: 52.sp,
          ),
        ),
      );
      if (moveCamera) {
        await _mapController.moveTo(point);
      }
    } catch (_) {}

    final areaLabel = await _resolveAreaLabel(point);
    if (!mounted) return;

    setState(() {
      _selectedAreaLabel = areaLabel;
      _isResolvingArea = false;
    });

    final state = context.read<DoctorsCubit>().state;
    if (state is DoctorsSuccess) {
      await _refreshNearbyDoctors(state.page.items);
    }
  }

  Future<String> _resolveAreaLabel(GeoPoint point) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isEmpty) return 'Selected area';
      final place = placemarks.first;
      final parts = [
        place.street,
        place.subLocality,
        place.locality,
      ].where((part) => part != null && part!.trim().isNotEmpty).cast<String>();
      return parts.isEmpty ? 'Selected area' : parts.join(', ');
    } catch (_) {
      return 'Selected area';
    }
  }

  Future<void> _refreshNearbyDoctors(List<Doctor> doctors) async {
    final selectedAreaPoint = _selectedAreaPoint;
    if (selectedAreaPoint == null) return;

    setState(() => _isRefreshingNearby = true);

    final nearbyDoctors = <_NearbyDoctorResult>[];
    for (final doctor in doctors) {
      final point = await _resolveDoctorPoint(doctor);
      if (point == null) continue;

      final distanceMeters = Geolocator.distanceBetween(
        selectedAreaPoint.latitude,
        selectedAreaPoint.longitude,
        point.latitude,
        point.longitude,
      );

      if (distanceMeters <= _radiusKm * 1000) {
        nearbyDoctors.add(
          _NearbyDoctorResult(
            doctor: HomeDoctorModel(doctor: doctor),
            distanceKm: distanceMeters / 1000,
          ),
        );
      }
    }

    nearbyDoctors.sort((first, second) {
      final distanceCompare = first.distanceKm.compareTo(second.distanceKm);
      if (distanceCompare != 0) return distanceCompare;
      return first.doctor.name.compareTo(second.doctor.name);
    });

    if (!mounted) return;
    setState(() {
      _nearbyDoctors = nearbyDoctors;
      _isRefreshingNearby = false;
    });
  }

  Future<GeoPoint?> _resolveDoctorPoint(Doctor doctor) async {
    final latitude = doctor.latitude;
    final longitude = doctor.longitude;
    if (latitude != null && longitude != null) {
      return GeoPoint(latitude: latitude, longitude: longitude);
    }

    if (_doctorLocationCache.containsKey(doctor.id)) {
      return _doctorLocationCache[doctor.id];
    }

    final address = doctor.clinicAddress;
    if (address == null || address.trim().isEmpty) {
      _doctorLocationCache[doctor.id] = null;
      return null;
    }

    try {
      final locations = await geo.locationFromAddress(address);
      if (locations.isEmpty) {
        _doctorLocationCache[doctor.id] = null;
        return null;
      }
      final location = locations.first;
      final point = GeoPoint(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _doctorLocationCache[doctor.id] = point;
      return point;
    } catch (_) {
      _doctorLocationCache[doctor.id] = null;
      return null;
    }
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.searchController,
    required this.selectedAreaLabel,
    required this.radiusKm,
    required this.isResolvingArea,
    required this.onSearchSubmitted,
    required this.onSearchPressed,
    required this.onRadiusChanged,
  });

  final TextEditingController searchController;
  final String selectedAreaLabel;
  final double radiusKm;
  final bool isResolvingArea;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchPressed;
  final ValueChanged<double> onRadiusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: AppSpacing.lg,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 18.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSearchSubmitted,
                    decoration: const InputDecoration(
                      hintText: 'Search doctor, specialty, hospital',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onSearchPressed,
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: colorScheme.primary,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 18.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.place_rounded,
                        color: colorScheme.primary,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected area',
                            style: context.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isResolvingArea
                                ? 'Updating location...'
                                : selectedAreaLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyMedium.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      'Search radius',
                      style: context.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '${radiusKm.toStringAsFixed(radiusKm < 10 ? 1 : 0)} km',
                        style: context.bodySmall.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: radiusKm,
                  min: 2,
                  max: 30,
                  divisions: 28,
                  label: '${radiusKm.toStringAsFixed(0)} km',
                  onChanged: onRadiusChanged,
                ),
                Text(
                  'Tip: tap anywhere on the map to search around that area.',
                  style: context.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyDoctorsSheet extends StatelessWidget {
  const _NearbyDoctorsSheet({
    required this.nearbyDoctors,
    required this.isLoading,
    required this.onDoctorTap,
  });

  final List<_NearbyDoctorResult> nearbyDoctors;
  final bool isLoading;
  final void Function(HomeDoctorModel doctor, int index) onDoctorTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.18,
      maxChildSize: 0.62,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 24.r,
                offset: Offset(0, -8.h),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Nearby doctors',
                      style: context.headingMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '${nearbyDoctors.length} found',
                        style: context.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? _NearbyDoctorsLoading(scrollController: scrollController)
                    : nearbyDoctors.isEmpty
                    ? _NearbyDoctorsEmpty(scrollController: scrollController)
                    : ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        itemCount: nearbyDoctors.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final result = nearbyDoctors[index];
                          return _NearbyDoctorTile(
                            doctor: result.doctor,
                            distanceKm: result.distanceKm,
                            onTap: () => onDoctorTap(result.doctor, index),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NearbyDoctorsLoading extends StatelessWidget {
  const _NearbyDoctorsLoading({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        itemCount: 3,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
        itemBuilder: (_, index) => _NearbyDoctorTile(
          doctor: HomeDoctorModel(
            doctor: Doctor(
              id: index + 1,
              fullName: 'Doctor Name',
              email: '',
              phone: '',
              specializationId: 0,
              specialization: const Specialization(id: 0, name: 'General'),
              isApproved: true,
              totalReviews: 120,
              createdAt: DateTime.now(),
              isAvailable: true,
              hospital: 'Hospital',
            ),
          ),
          distanceKm: 3.5,
          onTap: () {},
        ),
      ),
    );
  }
}

class _NearbyDoctorsEmpty extends StatelessWidget {
  const _NearbyDoctorsEmpty({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.all(AppSpacing.xl),
      children: [
        Icon(
          Icons.map_outlined,
          size: 56.sp,
          color: colorScheme.onSurfaceVariant,
        ),
        SizedBox(height: 12.h),
        Text(
          'No doctors found in this area yet.',
          textAlign: TextAlign.center,
          style: context.headingSmall.copyWith(color: colorScheme.onSurface),
        ),
        SizedBox(height: 8.h),
        Text(
          'Try tapping another point on the map or increasing the search radius.',
          textAlign: TextAlign.center,
          style: context.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NearbyDoctorTile extends StatelessWidget {
  const _NearbyDoctorTile({
    required this.doctor,
    required this.distanceKm,
    required this.onTap,
  });

  final HomeDoctorModel doctor;
  final double distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.h,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: colorScheme.primary,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.headingMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${doctor.speciality} • ${doctor.hospital}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 14.sp,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${distanceKm.toStringAsFixed(distanceKm < 10 ? 1 : 0)} km away',
                          style: context.bodySmall.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyDoctorResult {
  const _NearbyDoctorResult({required this.doctor, required this.distanceKm});

  final HomeDoctorModel doctor;
  final double distanceKm;
}
