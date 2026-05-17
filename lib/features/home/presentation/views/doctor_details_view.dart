import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:geocoding/geocoding.dart' as geo;

import 'package:doctor_appointment/features/doctors/logic/doctor_details_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/widgets/full_screen_image_viewer.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import '../widgets/doctor_details_widgets.dart';
import '../widgets/shared_app_bar.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({super.key, required this.doctor});
  final HomeDoctorModel doctor;

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
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) =>
          getIt<DoctorDetailsCubit>()
            ..loadDoctorDetails(int.parse(widget.doctor.id)),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: SharedAppBar(
          title: widget.doctor.name,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        Routes.chatView,
                        pathParameters: {'userId': widget.doctor.id.toString()},
                        extra: {
                          'otherUserName': widget.doctor.name,
                          'otherUserProfilePicture': widget.doctor.doctor.profilePictureUrl,
                        },
                      );
                    },
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.more_horiz_rounded,
                    color: colorScheme.onSurface,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            DoctorHeaderCard(doctor: widget.doctor),
            DoctorTabBar(controller: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AboutTab(doctor: widget.doctor),
                  _AddressTab(doctor: widget.doctor),
                  const _ReviewsTab(),
                ],
              ),
            ),
            _AppointmentButton(doctor: widget.doctor),
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
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        InfoSection(
          title: 'About me',
          content: doctor.doctor.bio ??
              'Dr. ${doctor.name} is a top specialist${doctor.doctor.hospital != null ? ' at ${doctor.doctor.hospital}' : ''}. They have received several awards for their outstanding contribution in the medical field and are available for private consultation.',
        ),
        SizedBox(height: AppSpacing.xl),
        if (doctor.doctor.yearsOfExperience != null) ...[
          LabelValue(
            label: 'Experience',
            value: '${doctor.doctor.yearsOfExperience} years',
          ),
          SizedBox(height: AppSpacing.lg),
        ],
        if (doctor.doctor.hospital != null) ...[
          LabelValue(label: 'Hospital', value: doctor.doctor.hospital!),
          SizedBox(height: AppSpacing.lg),
        ],
        LabelValue(label: 'Contact', value: doctor.doctor.phone),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _AddressTab extends StatelessWidget {
  const _AddressTab({required this.doctor});
  final HomeDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        LabelValue(
          label: 'Practice Place',
          value: doctor.doctor.clinicAddress ?? 'No address provided',
        ),
        if (doctor.doctor.clinicImagesUrls != null &&
            doctor.doctor.clinicImagesUrls!.isNotEmpty) ...[
          SizedBox(height: AppSpacing.xl),
          Text('Clinic Images', style: context.headingSmall),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: doctor.doctor.clinicImagesUrls!.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final imageUrl = ImageUrlHelper.getFullUrl(
                  doctor.doctor.clinicImagesUrls![index],
                );
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
                      imageUrl: imageUrl,
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
        SizedBox(height: AppSpacing.xl),
        Text('Location Map', style: context.headingSmall),
        SizedBox(height: AppSpacing.md),
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

              // Fallback to default Cairo if everything fails
              lat ??= 30.0444;
              lng ??= 31.2357;

              await availableMaps.first.showMarker(
                coords: Coords(lat, lng),
                title: doctor.doctor.clinicAddress ?? "Clinic Location",
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              height: 220.h,
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: CustomPaint(painter: _MiniMapPainter(colorScheme: colorScheme)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final ColorScheme colorScheme;
  _MiniMapPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = colorScheme.primaryContainer.withValues(alpha: 0.5);
    final roadPaint = Paint()
      ..color = colorScheme.surface
      ..strokeWidth = 10.w;
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 4; j++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(i * 80.w + 15.w, j * 70.h + 15.h, 55.w, 50.h),
            Radius.circular(8.r),
          ),
          blockPaint,
        );
      }
    }
    for (var i = 0; i <= 5; i++) {
      canvas.drawLine(
        Offset(i * 80.0.w, 0),
        Offset(i * 80.0.w, size.height),
        roadPaint,
      );
    }
    for (var j = 0; j <= 4; j++) {
      canvas.drawLine(
        Offset(0, j * 70.0.h),
        Offset(size.width, j * 70.0.h),
        roadPaint,
      );
    }
    final pin = Paint()..color = colorScheme.primary;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      18.r,
      Paint()..color = colorScheme.primary.withValues(alpha: 0.2),
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.r, pin);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      4.r,
      Paint()..color = colorScheme.onPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
      builder: (context, state) {
        if (state is DoctorDetailsLoading) {
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: 3,
              separatorBuilder: (_, _) =>
                  Divider(height: AppSpacing.xxl, color: colorScheme.outlineVariant),
              itemBuilder: (_, index) => _ReviewTile(
                name: 'Patient Name Loading',
                text: 'Review comment content loading placeholder text.',
                stars: 5,
                date: DateTime.now(),
              ),
            ),
          );
        } else if (state is DoctorDetailsError) {
          return Center(
            child: Text(
              state.message,
              style: context.bodyMedium.copyWith(color: colorScheme.error),
            ),
          );
        } else if (state is DoctorDetailsLoaded) {
          final reviews = state.reviews;
          if (reviews.isEmpty) {
            return Center(
              child: Text('No reviews yet', style: context.bodyMedium),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(AppSpacing.lg),
            itemCount: reviews.length,
            separatorBuilder: (_, _) =>
                Divider(height: AppSpacing.xxl, color: colorScheme.outlineVariant),
            itemBuilder: (_, index) => _ReviewTile(
              name: reviews[index].patientName,
              text: reviews[index].comment,
              stars: reviews[index].stars,
              date: reviews[index].createdAt,
            ),
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
    required this.date,
  });
  final String name;
  final String text;
  final int stars;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<AppCustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                name[0],
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.headingSmall),
                  Row(
                    children: List.generate(
                      stars,
                      (_) => Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: customColors.rating,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: context.bodySmall,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Text(text, style: context.bodyMedium.copyWith(height: 1.6)),
      ],
    );
  }
}

class _AppointmentButton extends StatelessWidget {
  const _AppointmentButton({required this.doctor});
  final HomeDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        height: 50.h,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    context.pushNamed(Routes.bookingDateView, extra: doctor.doctor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pushNamed(
                  Routes.chatView,
                  pathParameters: {'userId': doctor.id.toString()},
                  extra: {
                    'otherUserName': doctor.name,
                    'otherUserProfilePicture': doctor.doctor.profilePictureUrl,
                  },
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 1.5.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  'Chat',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
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
