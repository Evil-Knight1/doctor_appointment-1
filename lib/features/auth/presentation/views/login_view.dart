import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/circular_social_button.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_divider.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is AuthSuccess) {
          context.go(state.targetRoute);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).top -
                      MediaQuery.paddingOf(context).bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        Text('Welcome Back', style: AppStyles.styleBold32),
                        SizedBox(height: 8.h),
                        Text(
                          'We\'re excited to have you back, can\'t wait to see what you\'ve been up to since you last logged in.',
                          style: AppStyles.styleRegular14,
                        ),
                        SizedBox(height: 36.h),
                        CustomTextFormField(
                          hintText: 'Email',
                          textInputType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          hintText: 'Password',
                          textInputType: TextInputType.visiblePassword,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        SizedBox(height: 16.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              context.go(AppRouter.kForgotPasswordView);
                            },
                            child: Text(
                              'Forgot Password?',
                              style: AppStyles.styleRegular12.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            height: 52.h,
                            width: double.infinity,
                            text: isLoading ? 'Logging in...' : 'Login',
                            onPressed: isLoading
                                ? () {}
                                : () {
                                    if (_formKey.currentState?.validate() !=
                                        true) {
                                      return;
                                    }
                                    context.read<AuthCubit>().login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );
                                  },
                            buttonColor: AppColors.primary,
                            textStyle: AppStyles.styleSemiBold16.copyWith(
                              color: Colors.white,
                            ),
                            circleSize: 16.r,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        CustomDivider(),
                        SizedBox(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularSocialButton(
                              icon: Assets.imagesGoogle,
                              onTap: () {},
                            ),
                            SizedBox(width: 32.w),
                            CircularSocialButton(
                              icon: Assets.imagesFacebook,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: AppStyles.styleRegular14,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go(AppRouter.kUserSelectionView);
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: AppStyles.styleRegular14.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
