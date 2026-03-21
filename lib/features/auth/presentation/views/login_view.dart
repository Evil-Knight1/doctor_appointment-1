import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_divider.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_social_button.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is AuthSuccess) {
          context.go(AppRouter.kRoot);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h), // 37 ? 24
                        Text(
                          'Go ahead & set up your\naccount',
                          style: AppStyles.styleSemiBold24,
                        ),
                        SizedBox(height: 8.h), // 15 ? 8
                        Text(
                          'Welcome back! Please sign in to manage your account.',
                          style: AppStyles.styleRegular14,
                        ),
                        SizedBox(height: 24.h), // 48 ? 24
                        Text('Email', style: AppStyles.styleMedium14),
                        SizedBox(height: 8.h), // 15 ? 8
                        CustomTextFormField(
                          hintText: 'Enter your Email',
                          textInputType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        SizedBox(height: 16.h), // 30 ? 16
                        Text('Password', style: AppStyles.styleMedium14),
                        SizedBox(height: 8.h), // 15 ? 8
                        CustomTextFormField(
                          hintText: 'Password',
                          textInputType: TextInputType.visiblePassword,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        SizedBox(height: 10.h), // 30 ? 10
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: AppStyles.styleRegular12.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h), // 30 ? 20
                        Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            height: 49.h,
                            width: 328.w,
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
                                          password:
                                              _passwordController.text.trim(),
                                        );
                                  },
                            buttonColor: const Color(0xff236DEC),
                            textStyle: AppStyles.styleSemiBold16,
                            circleSize: 10.r,
                          ),
                        ),
                        SizedBox(height: 24.h), // 48 ? 24
                        CustomDivider(),
                        SizedBox(height: 24.h), // 48 ? 24
                        Row(
                          children: [
                            Expanded(
                              child: CustomSocialButton(
                                label: 'Google',
                                iconPath: 'assets/images/google.svg',
                                onTap: () {},
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: CustomSocialButton(
                                label: 'Facebook',
                                iconPath: 'assets/images/facebook.svg',
                                onTap: () {},
                              ),
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
                                  style: AppStyles.styleRegular14.copyWith(
                                    color: const Color(0xFF949D9E),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go(AppRouter.kSignUpView);
                                  },
                                  child: Text(
                                    'Register',
                                    style: AppStyles.styleMedium14.copyWith(
                                      color: const Color(0xFF1A73E8),
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
