import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/shared_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_state.dart';

class BookingReviewView extends StatefulWidget {
  const BookingReviewView({super.key, required this.doctor});
  final Doctor doctor;

  @override
  State<BookingReviewView> createState() => _BookingReviewViewState();
}

class _BookingReviewViewState extends State<BookingReviewView> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const SharedAppBar(title: 'Write a Review'),
      body: BlocConsumer<DoctorDetailsCubit, DoctorDetailsState>(
        listener: (context, state) {
          if (state is DoctorDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is DoctorDetailsLoaded) {
            // If we are in the review view, it means we probably just submitted one
            // because the go_router provides the cubit and loads details.
            // But we need a more specific way to know if it was a success.
            // Actually, DoctorDetailsCubit.addReview calls loadDoctorDetails.
          }
        },
        builder: (context, state) {
          final isLoading = state is DoctorDetailsLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                SizedBox(height: AppSpacing.xl),
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 50.sp,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'How was your experience with',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(widget.doctor.fullName, style: AppTextStyles.headingLarge),
                SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSelected = index < _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = index + 1),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          Icons.star_rounded,
                          size: 40.sp,
                          color: isSelected ? AppColors.star : AppColors.divider,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: AppSpacing.xxl),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10.r,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _reviewController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      hintStyle: AppTextStyles.bodySmall,
                      contentPadding: EdgeInsets.all(AppSpacing.lg),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xxl * 2),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: (_rating == 0 || isLoading)
                        ? null
                        : () async {
                            await context.read<DoctorDetailsCubit>().addReview(
                              doctorId: widget.doctor.id,
                              stars: _rating,
                              comment: _reviewController.text,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review submitted successfully!'),
                                ),
                              );
                              context.goNamed(Routes.homeView);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.divider,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit Review',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
