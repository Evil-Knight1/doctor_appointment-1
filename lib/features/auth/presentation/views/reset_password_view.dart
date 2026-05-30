import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/logic/forgot_password_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/forgot_password_state.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String token;
  const ResetPasswordView({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Map<String, String> _fieldErrors = {};

  String? _getServerError(String key) => _fieldErrors[key.toLowerCase()];

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        }
        if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.passwordResetSuccessfully)),
          );
          // Navigate to login screen and clear history
          context.go(AppRouter.kLoginView);
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
                    Text(AppLocalizations.of(context)!.resetPasswordTitle, style: context.styleBold32),
                    SizedBox(height: 8.h),
                    Text(
                      AppLocalizations.of(context)!.enterNewPassword,
                      style: context.styleRegular14,
                    ),
                    SizedBox(height: 36.h),
                    CustomTextFormField(
                      hintText: AppLocalizations.of(context)!.newPassword,
                      textInputType: TextInputType.visiblePassword,
                      isPassword: true,
                      controller: _passwordController,
                      serverError: _getServerError('newpassword') ?? _getServerError('password'),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormField(
                      hintText: AppLocalizations.of(context)!.confirmPassword,
                      textInputType: TextInputType.visiblePassword,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      serverError: _getServerError('confirmpassword'),
                    ),
                    SizedBox(height: 32.h),
                    Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                        height: 52.h,
                        width: double.infinity,
                        text: isLoading ? AppLocalizations.of(context)!.resetting : AppLocalizations.of(context)!.resetPasswordTitle,
                        onPressed: isLoading
                            ? () {}
                            : () {
                                setState(() => _fieldErrors = {});
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }
                                if (_passwordController.text.trim() !=
                                    _confirmPasswordController.text.trim()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                  return;
                                }
                                context
                                    .read<ForgotPasswordCubit>()
                                    .resetPassword(
                                      email: widget.email,
                                      token: widget.token,
                                      newPassword: _passwordController.text
                                          .trim(),
                                    );
                              },
                        buttonColor: Theme.of(context).colorScheme.primary,
                        textStyle: context.styleSemiBold16.copyWith(
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
