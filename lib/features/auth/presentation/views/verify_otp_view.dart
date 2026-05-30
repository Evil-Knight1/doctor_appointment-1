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
import 'package:pinput/pinput.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

class VerifyOtpView extends StatefulWidget {
  final String email;
  const VerifyOtpView({super.key, required this.email});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is OtpVerifiedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.otpVerifiedSuccessfully)),
          );
          context.pushReplacement(
            AppRouter.kResetPasswordView,
            extra: {
              'email': widget.email,
              'token': state.token,
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
                      AppLocalizations.of(context)!.verifyOtpTitle,
                      style: context.styleBold32,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppLocalizations.of(context)!.verifyOtpSubtitle(widget.email),
                      style: context.styleRegular14,
                    ),
                    SizedBox(height: 36.h),
                    Align(
                      alignment: Alignment.center,
                      child: Pinput(
                        controller: _otpController,
                        length: 6,
                        defaultPinTheme: PinTheme(
                          width: 50.w,
                          height: 56.h,
                          textStyle: context.styleBold32.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 50.w,
                          height: 56.h,
                          textStyle: context.styleBold32.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onCompleted: (pin) {
                          if (_formKey.currentState?.validate() != true) return;
                          context.read<ForgotPasswordCubit>().verifyOtp(
                                widget.email,
                                pin,
                              );
                        },
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                        height: 52.h,
                        width: double.infinity,
                        text: isLoading ? AppLocalizations.of(context)!.verifying : AppLocalizations.of(context)!.verify,
                        onPressed: isLoading
                            ? () {}
                            : () {
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }
                                context.read<ForgotPasswordCubit>().verifyOtp(
                                      widget.email,
                                      _otpController.text.trim(),
                                    );
                              },
                        buttonColor: Theme.of(context).colorScheme.primary,
                        textStyle: context.bodyMedium.copyWith(
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
