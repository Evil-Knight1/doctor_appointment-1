import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/features/doctor_details/presentation/widgets/doctor_info_widget.dart';
import 'package:doctor_appointment/features/doctor_details/presentation/widgets/doctor_stats_widget.dart';
import 'package:doctor_appointment/features/doctor_details/presentation/widgets/doctor_working_time_widget.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/widgets/full_screen_image_viewer.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:geocoding/geocoding.dart' as geo;

class DoctorDetailsView extends StatefulWidget {
  final HomeDoctorModel doctor;
  const DoctorDetailsView({super.key, required this.doctor});

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: DoctorInfoWidget(doctor: widget.doctor),
              ),
              SliverToBoxAdapter(
                child: DoctorStatsWidget(
                  rating: widget.doctor.rating,
                  reviewCount: widget.doctor.reviewCount,
                  yearsOfExperience:
                      widget.doctor.doctor.yearsOfExperience ?? 5,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              SliverToBoxAdapter(child: _buildTabBar()),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _AboutTab(doctor: widget.doctor),
                    _AddressTab(doctor: widget.doctor),
                    const _ReviewsTab(),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: context.styleSemiBold16.copyWith(fontSize: 13.sp),
        unselectedLabelStyle: context.styleRegular14.copyWith(fontSize: 13.sp),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Location'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300.h,
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.4),
          child: Hero(
            tag: 'doctor-${widget.doctor.id}',
            child: widget.doctor.doctor.profilePictureUrl != null
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            images: [
                              ImageUrlHelper.getFullUrl(
                                widget.doctor.doctor.profilePictureUrl,
                              ),
                            ],
                            initialIndex: 0,
                          ),
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullUrl(
                        widget.doctor.doctor.profilePictureUrl,
                      ),
                      httpHeaders: ImageUrlHelper.getImageHeaders(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Skeletonizer(
                        enabled: true,
                        child: Container(
                          width: double.infinity,
                          height: 300.h,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      errorWidget: (_, _, _) => Icon(
                        Icons.person,
                        size: 80.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 80.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
        ),
        Positioned(
          top: 48.h,
          left: 20.w,
          child: _buildHeaderButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
          ),
        ),
        Positioned(
          top: 48.h,
          right: 20.w,
          child: Row(
            children: [
              _buildHeaderButton(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {
                  context.pushNamed(
                    Routes.chatView,
                    pathParameters: {
                      'userId': widget.doctor.doctor.id.toString(),
                    },
                    extra: widget.doctor.name,
                  );
                },
              ),
              SizedBox(width: 10.w),
              ValueListenableBuilder<int>(
                valueListenable: SharedPreferencesHelper.favoritesVersion,
                builder: (context, _, _) {
                  final isFav = SharedPreferencesHelper.isDoctorFavorite(
                    widget.doctor.name,
                  );
                  return _buildHeaderButton(
                    icon: isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    color: isFav
                        ? context.customColors.error
                        : Theme.of(context).colorScheme.onSurface,
                    onTap: () async =>
                        await SharedPreferencesHelper.toggleFavoriteDoctor(
                          widget.doctor,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          top: 52.h,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              widget.doctor.name,
              style: context.styleMedium14.copyWith(
                fontSize: 15.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 10.r,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => context.pushNamed(
                  Routes.chatView,
                  pathParameters: {
                    'userId': widget.doctor.doctor.id.toString(),
                  },
                  extra: widget.doctor.name,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  minimumSize: Size(double.infinity, 52.h),
                  elevation: 0,
                ),
                child: Text(
                  'Chat',
                  style: context.styleSemiBold16.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => context.pushNamed(
                  Routes.bookingDateView,
                  extra: widget.doctor.doctor, // Passing the entity
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  minimumSize: Size(double.infinity, 52.h),
                  elevation: 0,
                ),
                child: Text(
                  'Book Appointment',
                  style: context.styleSemiBold16.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.doctor});
  final HomeDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('About', style: context.styleSemiBold22.copyWith(fontSize: 16.sp)),
        SizedBox(height: 8.h),
        Text(
          doctor.doctor.bio ??
              'Dr. ${doctor.name} is a top specialist${doctor.doctor.hospital != null ? ' at ${doctor.doctor.hospital}' : ''}. They have received several awards for their outstanding contribution in the medical field and are available for private consultation.',
          style: context.styleRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        if (doctor.doctor.hospital != null) ...[
          SizedBox(height: 20.h),
          Text(
            'Hospital',
            style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            doctor.doctor.hospital!,
            style: context.styleRegular14.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: 20.h),
        DoctorWorkingTimeWidget(),
        SizedBox(height: 100.h), // padding for bottom buttons
      ],
    );
  }
}

class _AddressTab extends StatelessWidget {
  const _AddressTab({required this.doctor});
  final HomeDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          'Clinic Address',
          style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          doctor.doctor.clinicAddress ?? 'No address provided',
          style: context.styleRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (doctor.doctor.clinicImagesUrls != null &&
            doctor.doctor.clinicImagesUrls!.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            'Clinic Images',
            style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: doctor.doctor.clinicImagesUrls!.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          images: doctor.doctor.clinicImagesUrls!
                              .map((url) => ImageUrlHelper.getFullUrl(url))
                              .toList(),
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullUrl(
                        doctor.doctor.clinicImagesUrls![index],
                      ),
                      httpHeaders: ImageUrlHelper.getImageHeaders(),
                      width: 140.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Skeletonizer(
                        enabled: true,
                        child: Container(
                          width: 140.w,
                          height: 100.h,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 140.w,
                        height: 100.h,
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        SizedBox(height: 30.h),
        Text(
          'Clinic Location',
          style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () async {
            final availableMaps = await MapLauncher.installedMaps;
            if (availableMaps.isNotEmpty) {
              double? lat = doctor.doctor.latitude;
              double? lng = doctor.doctor.longitude;

              // If coordinates are missing, try geocoding the address
              if (lat == null && doctor.doctor.clinicAddress != null) {
                try {
                  final locations = await geo.locationFromAddress(
                    doctor.doctor.clinicAddress!,
                  );
                  if (locations.isNotEmpty) {
                    lat = locations.first.latitude;
                    lng = locations.first.longitude;
                  }
                } catch (e) {
                  debugPrint('Geocoding error: $e');
                }
              }

              lat ??= 30.0444;
              lng ??= 31.2357;

              await availableMaps.first.showMarker(
                coords: Coords(lat, lng),
                title: doctor.doctor.clinicAddress ?? "Clinic Location",
              );
            }
          },
          child: Container(
            height: 160.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: const DecorationImage(
                image: AssetImage('assets/images/map_placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 10.r,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 100.h),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
      builder: (context, state) {
        if (state is DoctorDetailsLoading) {
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(
                height: 30.h,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) => const _ReviewTile(
                name: 'Patient Name',
                text:
                    'This is a placeholder review text that will be skeletonized during loading.',
                stars: 5,
              ),
            ),
          );
        } else if (state is DoctorDetailsError) {
          return Center(child: Text(state.message));
        } else if (state is DoctorDetailsLoaded) {
          final reviews = state.reviews;
          final doctorId = context.read<DoctorDetailsCubit>().doctorId ?? 0;
          return ListView(
            padding: EdgeInsets.all(20.w),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${reviews.length} Reviews',
                    style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddReviewDialog(context, doctorId),
                    icon: Icon(
                      Icons.add,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'Add Review',
                      style: context.styleMedium14.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (reviews.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text('No reviews yet', style: context.styleMedium14),
                  ),
                )
              else
                ...reviews.map(
                  (review) => Column(
                    children: [
                      _ReviewTile(
                        name: review.patientName,
                        text: review.comment,
                        stars: review.stars,
                      ),
                      Divider(
                        height: 30.h,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 100.h), // padding for bottom buttons
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAddReviewDialog(BuildContext context, int doctorId) {
    final commentController = TextEditingController();
    int selectedStars = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () => setState(() => selectedStars = index + 1),
                    icon: Icon(
                      index < selectedStars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: context.customColors.rating,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your review...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  context.read<DoctorDetailsCubit>().addReview(
                    doctorId: doctorId,
                    stars: selectedStars,
                    comment: commentController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.name,
    required this.text,
    required this.stars,
  });
  final String name;
  final String text;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Anonymous',
                    style: context.styleSemiBold16.copyWith(fontSize: 14.sp),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: index < stars
                            ? context.customColors.rating
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('Today', style: context.styleRegular12),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          text,
          style: context.styleRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
