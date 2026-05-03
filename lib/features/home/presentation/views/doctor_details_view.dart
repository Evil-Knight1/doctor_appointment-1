import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/doctor_details_widgets.dart';
import '../widgets/shared_app_bar.dart';

class DoctorDetailView extends StatefulWidget {
  const DoctorDetailView({super.key, required this.doctor});
  final DoctorModel doctor;

  @override
  State<DoctorDetailView> createState() => _DoctorDetailViewState();
}

class _DoctorDetailViewState extends State<DoctorDetailView>
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
      backgroundColor: AppColors.backgroundLight,
      appBar: SharedAppBar(
        title: widget.doctor.name,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textPrimary,
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
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.doctor});
  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        InfoSection(
          title: 'About me',
          content:
              'Dr. ${doctor.name} is a top specialist at RSUD Gatot Subroto. They have received several awards for their outstanding contribution in the medical field and are available for private consultation.',
        ),
        SizedBox(height: AppSpacing.xl),
        const LabelValue(
          label: 'Working Time',
          value: 'Monday - Friday, 08:00 AM - 20:00 PM',
        ),
        SizedBox(height: AppSpacing.lg),
        const LabelValue(label: 'STR', value: '4726482464'),
        SizedBox(height: AppSpacing.lg),
        const LabelValue(
          label: 'Pengalaman Praktik',
          value: 'RSPAD Gatot Soebroto\n2017 - sekarang',
        ),
      ],
    );
  }
}

class _AddressTab extends StatelessWidget {
  const _AddressTab({required this.doctor});
  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        const LabelValue(label: 'Practice Place', value: 'Cairo, Egypt'),
        SizedBox(height: AppSpacing.xl),
        Text('Location Map', style: AppTextStyles.headingSmall),
        SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            height: 220.h,
            color: const Color(0xFFE8F0FE),
            child: CustomPaint(painter: _MiniMapPainter()),
          ),
        ),
      ],
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = const Color(0xFFDDE6FB);
    final roadPaint = Paint()
      ..color = Colors.white
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
    final pin = Paint()..color = AppColors.primary;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      18.r,
      Paint()..color = AppColors.primary.withValues(alpha: 0.2),
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.r, pin);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      4.r,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  static const _reviews = [
    (
      'Jane Cooper',
      'As someone who lives in a remote area, this telemedicine app has been a game changer. I can easily schedule virtual appointments.',
      5,
    ),
    (
      'Robert Fox',
      'I was initially skeptical but this app has exceeded my expectations. The doctors are highly qualified and provide excellent care.',
      5,
    ),
    (
      'Jacob Jones',
      'Very professional team. Booking was seamless and the doctor was punctual and thorough during consultation.',
      5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: _reviews.length,
      separatorBuilder: (_, _) =>
          Divider(height: AppSpacing.xxl, color: AppColors.divider),
      itemBuilder: (_, index) => _ReviewTile(
        name: _reviews[index].$1,
        text: _reviews[index].$2,
        stars: _reviews[index].$3,
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
              radius: 20.r,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                name[0],
                style: TextStyle(
                  color: AppColors.primary,
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
                  Text(name, style: AppTextStyles.headingSmall),
                  Row(
                    children: List.generate(
                      stars,
                      (_) => Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: AppColors.star,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('Today', style: AppTextStyles.bodySmall),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Text(text, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
      ],
    );
  }
}

class _AppointmentButton extends StatelessWidget {
  const _AppointmentButton({required this.doctor});
  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        height: 50.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.pushNamed(
            Routes.bookingDateView,
            extra: doctor,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
          ),
          child: Text(
            'Make An Appointment',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
