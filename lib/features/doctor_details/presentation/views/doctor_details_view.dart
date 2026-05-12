import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
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
      backgroundColor: Colors.white,
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppStyles.styleSemiBold16.copyWith(fontSize: 13.sp),
        unselectedLabelStyle: AppStyles.styleRegular14.copyWith(
          fontSize: 13.sp,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
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
          color: AppColors.primaryLight,
          child: widget.doctor.doctor.profilePictureUrl != null
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          images: [ImageUrlHelper.getFullUrl(widget.doctor.doctor.profilePictureUrl)],
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: ImageUrlHelper.getFullUrl(widget.doctor.doctor.profilePictureUrl),
                                  httpHeaders: ImageUrlHelper.getImageHeaders(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (_, _, _) => Icon(Icons.person,
                        size: 80.sp, color: AppColors.primary),
                  ),
                )
              : Icon(Icons.person, size: 80.sp, color: AppColors.primary),
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
                    color: isFav ? AppColors.accent : AppColors.textPrimary,
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
              style: AppStyles.styleMedium14.copyWith(fontSize: 15.sp),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: color ?? AppColors.textPrimary),
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
        color: Colors.white,
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
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  minimumSize: Size(double.infinity, 52.h),
                  elevation: 0,
                ),
                child: Text(
                  'Chat',
                  style: AppStyles.styleSemiBold16.copyWith(color: AppColors.primary),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  minimumSize: Size(double.infinity, 52.h),
                  elevation: 0,
                ),
                child: Text(
                  'Book Appointment',
                  style: AppStyles.styleSemiBold16.copyWith(color: Colors.white),
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
        Text(
          'About',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          doctor.doctor.bio ??
              'Dr. ${doctor.name} is a top specialist. They have received several awards for their outstanding contribution in the medical field and are available for private consultation.',
          style: AppStyles.styleRegular14.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        SizedBox(height: 20.h),
        const DoctorWorkingTimeWidget(),
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
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          doctor.doctor.clinicAddress ?? 'No address provided',
          style: AppStyles.styleRegular14.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (doctor.doctor.clinicImagesUrls != null &&
            doctor.doctor.clinicImagesUrls!.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            'Clinic Images',
            style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
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
                          images: doctor.doctor.clinicImagesUrls!.map((url) => ImageUrlHelper.getFullUrl(url)).toList(),
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullUrl(doctor.doctor.clinicImagesUrls![index]),
                                  httpHeaders: ImageUrlHelper.getImageHeaders(),
                      width: 150.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 150.w,
                        height: 100.h,
                        color: AppColors.primaryLight,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 150.w,
                        height: 100.h,
                        color: AppColors.primaryLight,
                        child: Icon(Icons.image_not_supported,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        SizedBox(height: 20.h),
        Text(
          'Location Map',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () async {
            final availableMaps = await MapLauncher.installedMaps;
            if (availableMaps.isNotEmpty) {
              await availableMaps.first.showMarker(
                coords: Coords(30.0444, 31.2357), // Default Cairo coords
                title: doctor.name,
                description: 'Clinic Location',
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              height: 200.h,
              color: AppColors.primaryLight,
              child: Center(
                child: Icon(
                  Icons.map_rounded,
                  color: AppColors.primary,
                  size: 40.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 100.h), // padding for bottom buttons
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  void _showAddReviewDialog(BuildContext context, int doctorId) {
    int selectedStars = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedStars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.star,
                          size: 32.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedStars = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final comment = commentController.text.trim();
                    if (comment.isNotEmpty) {
                      context.read<DoctorDetailsCubit>().addReview(
                            doctorId: doctorId,
                            stars: selectedStars,
                            comment: comment,
                          );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
      builder: (context, state) {
        if (state is DoctorDetailsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DoctorDetailsError) {
          return Center(
            child: Text(
              state.message,
              style: AppStyles.styleMedium14.copyWith(color: AppColors.error),
            ),
          );
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
                    style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddReviewDialog(context, doctorId),
                    icon: Icon(Icons.add, size: 20.sp, color: AppColors.primary),
                    label: Text(
                      'Add Review',
                      style: AppStyles.styleMedium14.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (reviews.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text('No reviews yet', style: AppStyles.styleMedium14),
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
                      Divider(height: 30.h, color: AppColors.border),
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
              backgroundColor: AppColors.primaryLight,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: AppColors.primary,
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
                    style: AppStyles.styleSemiBold16.copyWith(fontSize: 14.sp),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: index < stars
                            ? AppColors.star
                            : AppColors.divider,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('Today', style: AppStyles.styleRegular12),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          text,
          style: AppStyles.styleRegular14.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
