import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/on_boarding_view/data/models/on_boarding_view_model.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnBoardingViewModel> pages = [
    OnBoardingViewModel(
      title: 'Your Health, Our Priority',
      description:
          'We look after the well-being of your entire family. Find the right doctor and book an appointment with complete peace of mind',
      image: 'assets/images/Group 1.png',
    ),
    OnBoardingViewModel(
      title: 'Take Care of Your Loved Ones',
      description:
          'From pediatrics to general medicine and beyond, manage your whole family\'s health simply, quickly, and securely.',
      image: 'assets/images/Group 2.png',
    ),
    OnBoardingViewModel(
      title: 'Your Family Health Partner',
      description:
          'Because your family\'s health is precious, we put the best healthcare professionals within your reach.',
      image: 'assets/images/Group 3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  /// Background Image
                  Positioned.fill(
                    child: Image.asset(pages[index].image, fit: BoxFit.cover),
                  ),

                  /// Dark Overlay
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),

                  /// Bottom White Container (FIXED VERSION)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.r),
                          topRight: Radius.circular(25.r),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 30.h,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// Title
                                Text(
                                  pages[index].title,
                                  style: AppStyles.styleSemiBold22,
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 15.h),

                                /// Description
                                Text(
                                  pages[index].description,
                                  style: AppStyles.styleRegular14,
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 30.h),

                                /// Dots Indicator
                                DotsIndicator(
                                  pages: pages,
                                  currentIndex: _currentIndex,
                                ),

                                SizedBox(height: 30.h),

                                /// Button
                                CustomButton(
                                  height: 50.h,
                                  width: double.infinity,
                                  text: _currentIndex == pages.length - 1
                                      ? 'Get Started'
                                      : 'Next',
                                  onPressed: () async {
                                    if (_currentIndex == pages.length - 1) {
                                      await SharedPreferencesHelper.saveHasSeenOnboarding(true);
                                      if (context.mounted) context.go(AppRouter.kLoginView);
                                    } else {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  buttonColor: const Color(0xff236DEC),
                                  textStyle: AppStyles.styleSemiBold16.copyWith(
                                    color: Colors.white,
                                  ),
                                  circleSize: 12.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          /// Skip Button
          Positioned(
            top: 20.h,
            right: 20.w,
            child: SafeArea(
              child: TextButton(
                onPressed: () async {
                  await SharedPreferencesHelper.saveHasSeenOnboarding(true);
                  if (context.mounted) context.go(AppRouter.kLoginView);
                },
                child: Text(
                  'Skip',
                  style: AppStyles.styleSemiBold16.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
