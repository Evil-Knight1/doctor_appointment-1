import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_approval_notice.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_signup_footer.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_signup_form.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_signup_header.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:go_router/go_router.dart';

/// Standalone doctor registration view.
/// Since the backend does not yet have a doctor-register endpoint, this form
/// collects all professional fields and navigates to the pending-approval
/// screen on submission — matching the existing behaviour.
class DoctorSignUpView extends StatefulWidget {
  const DoctorSignUpView({super.key});

  @override
  State<DoctorSignUpView> createState() => _DoctorSignUpViewState();
}

class _DoctorSignUpViewState extends State<DoctorSignUpView> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // --- Controllers ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _yearsController = TextEditingController();
  final _licenseController = TextEditingController();
  final _bioController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _hospitalController = TextEditingController();

  // Controllers and FocusNodes are handled inside DoctorSignUpForm or passed to it.
  // We keep controllers here because they are needed for _submitForm.

  // --- Specializations ---
  final Set<String> _selectedSpecializations = {};
  late final SpecializationsCubit _specializationsCubit;

  @override
  void initState() {
    super.initState();
    _specializationsCubit = getIt<SpecializationsCubit>();
    _specializationsCubit.fetchSpecializations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _yearsController.dispose();
    _licenseController.dispose();
    _bioController.dispose();
    _clinicAddressController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPickerSheet(
        onLocationSelected: (address) {
          setState(() {
            _clinicAddressController.text = address;
          });
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() != true) return;

    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one specialization'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        context.push(AppRouter.kDoctorPendingApprovalView);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _specializationsCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DoctorSignUpHeader(),
                        SizedBox(height: 20.h),
                        const DoctorApprovalNotice(),
                        SizedBox(height: 28.h),

                        DoctorSignUpForm(
                          formKey: _formKey,
                          onShowLocationPicker: _showLocationPicker,
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          yearsController: _yearsController,
                          licenseController: _licenseController,
                          bioController: _bioController,
                          clinicAddressController: _clinicAddressController,
                          hospitalController: _hospitalController,
                          selectedSpecializations: _selectedSpecializations,
                        ),
                        SizedBox(height: 32.h),

                        DoctorSignUpFooter(
                          isLoading: _isSubmitting,
                          onSubmit: _submitForm,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final Function(String) onLocationSelected;
  const _LocationPickerSheet({required this.onLocationSelected});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late MapController _controller;
  String _address = 'Loading...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateAddress(GeoPoint position) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address = '${p.street}, ${p.subLocality}, ${p.locality}';
        });
      }
    } catch (e) {
      setState(() => _address = 'Unknown Location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Clinic Location',
                  style: AppStyles.styleSemiBold18,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                OSMFlutter(
                  controller: _controller,
                  osmOption: OSMOption(
                    userTrackingOption: const UserTrackingOption(
                      enableTracking: true,
                      unFollowUser: false,
                    ),
                    zoomOption: const ZoomOption(
                      initZoom: 15,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.location_history_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      directionArrowMarker: const MarkerIcon(
                        icon: Icon(Icons.double_arrow, size: 48),
                      ),
                    ),
                    roadConfiguration: const RoadOption(
                      roadColor: Colors.yellowAccent,
                    ),
                  ),
                  onGeoPointClicked: (geoPoint) async {
                    try {
                      await _controller.removeMarkers([geoPoint]); // Avoid duplicates if needed, though addMarker usually handles it
                      await _controller.addMarker(
                        geoPoint,
                        markerIcon: const MarkerIcon(
                          icon: Icon(Icons.location_on, color: Colors.blue, size: 48),
                        ),
                      );
                      _updateAddress(geoPoint);
                    } catch (e) {
                      debugPrint('Error adding marker: $e');
                    }
                  },
                  onMapIsReady: (isReady) async {
                    if (isReady) {
                      try {
                        final point = await _controller.myLocation();
                        await _controller.addMarker(
                          point,
                          markerIcon: const MarkerIcon(
                            icon: Icon(Icons.person_pin_circle, color: Colors.blue, size: 56),
                          ),
                        );
                        _updateAddress(point);
                      } catch (e) {
                        debugPrint('Error getting location: $e');
                      }
                    }
                  },
                ),
                Positioned(
                  bottom: 100.h,
                  right: 20.w,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      try {
                        await _controller.currentLocation();
                        final point = await _controller.myLocation();
                        _updateAddress(point);
                      } catch (e) {
                        debugPrint('Error getting current location: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not get current location')),
                          );
                        }
                      }
                    },
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _address,
                        style: AppStyles.styleMedium14,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _SubmitButton(
                  isLoading: _isLoading,
                  label: 'Confirm Location',
                  onPressed: () {
                    widget.onLocationSelected(_address);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.label,
    this.onPressed,
  });
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff236DEC),
          disabledBackgroundColor: const Color(
            0xff236DEC,
          ).withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(label, style: AppStyles.styleSemiBold16),
                ],
              ),
      ),
    );
  }
}
