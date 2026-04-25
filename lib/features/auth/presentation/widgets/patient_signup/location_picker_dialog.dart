import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({super.key});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late MapController _mapController;
  bool _isLoading = false;
  GeoPoint? _selectedPoint;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: GeoPoint(latitude: 36.8065, longitude: 10.1815), // Default to Tunis, for example
      areaLimit: BoundingBox(
        east: 10.499998,
        north: 47.258333,
        south: 28.166667,
        west: -1.759534,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedPoint!.latitude,
        _selectedPoint!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _address = '${place.street}, ${place.locality}, ${place.country}';
      } else {
        _address = '${_selectedPoint!.latitude}, ${_selectedPoint!.longitude}';
      }
      
      if (mounted) {
        Navigator.of(context).pop(_address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get address. Try again.')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        height: 500.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              'Select Address',
              style: AppStyles.styleSemiBold18,
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: OSMFlutter(
                  controller: _mapController,
                  osmOption: OSMOption(
                    userTrackingOption: const UserTrackingOption(
                      enableTracking: false,
                      unFollowUser: false,
                    ),
                    zoomOption: const ZoomOption(
                      initZoom: 12,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                  ),
                  onMapIsReady: (isReady) {
                    if (isReady) {
                      // Map is ready
                    }
                  },
                  onGeoPointClicked: (geoPoint) {
                    setState(() {
                      _selectedPoint = geoPoint;
                    });
                    _mapController.addMarker(
                      geoPoint,
                      markerIcon: const MarkerIcon(
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            if (_selectedPoint != null) ...[
              Text(
                'Location selected!',
                style: AppStyles.styleMedium14.copyWith(color: Colors.green),
              ),
              SizedBox(height: 8.h),
            ],
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff236DEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Confirm Location',
                        style: AppStyles.styleSemiBold16.copyWith(
                          color: Colors.white,
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
