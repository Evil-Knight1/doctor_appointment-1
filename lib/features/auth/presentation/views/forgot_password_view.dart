import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/logic/forgot_password_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/forgot_password_state.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  Map<String, String> _fieldErrors = {};

  String? _getServerError(String key) => _fieldErrors[key.toLowerCase()];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordFailure) {
          setState(() {
            _fieldErrors = state.fieldErrors;
          });
          if (state.fieldErrors.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
        if (state is ForgotPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          // Skip OTP and go directly to Reset Password
          context.push(
            AppRouter.kResetPasswordView,
            extra: {
              'email': _emailController.text.trim(),
              'token': 'dummy-token-bypass-otp',
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ForgotPasswordLoading;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      'Forgot Password',
                      style: AppStyles.styleBold32,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your email address to receive a verification code.',
                      style: AppStyles.styleRegular14,
                    ),
                    SizedBox(height: 36.h),
                    CustomTextFormField(
                      hintText: 'Email',
                      textInputType: TextInputType.emailAddress,
                      controller: _emailController,
                      serverError: _getServerError('email'),
                    ),
                    SizedBox(height: 32.h),
                    Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                        height: 52.h,
                        width: double.infinity,
                        text: isLoading ? 'Sending...' : 'Send OTP',
                        onPressed: isLoading
                            ? () {}
                            : () {
                                setState(() => _fieldErrors = {});
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }
                                context.read<ForgotPasswordCubit>().forgotPassword(
                                      _emailController.text.trim(),
                                    );
                              },
                        buttonColor: AppColors.primary,
                        textStyle: AppStyles.styleSemiBold16.copyWith(
                          color: Colors.white,
                        ),
                        circleSize: 16.r,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
