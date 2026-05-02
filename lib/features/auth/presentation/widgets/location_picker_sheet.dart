import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationPickerSheet extends StatefulWidget {
  final String title;
  final Function(String) onLocationSelected;
  const LocationPickerSheet({
    super.key,
    required this.title,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  late MapController _controller;
  final _searchController = TextEditingController();
  String _address = 'Loading...';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: true, // Fix stiff map: allow user to move freely
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      List<geo.Location> locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final point = GeoPoint(
          latitude: loc.latitude,
          longitude: loc.longitude,
        );
        await _controller.moveTo(point);
        await _controller.addMarker(
          point,
          markerIcon: const MarkerIcon(
            icon: Icon(Icons.location_on, color: Colors.blue, size: 48),
          ),
        );
        _updateAddress(point);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location not found')));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
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

  final bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 16.h),
            width: 40.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppStyles.styleBold18.copyWith(
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.textTheme.headlineLarge?.color,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                      unFollowUser:
                          true, // Fix stiff map: allow user to move freely
                    ),
                    zoomOption: const ZoomOption(
                      initZoom: 15,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: MarkerIcon(
                        icon: Icon(
                          Icons.location_history_rounded,
                          color: theme.colorScheme.error,
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
                      await _controller.removeMarkers(
                        [geoPoint],
                      ); // Avoid duplicates if needed, though addMarker usually handles it
                      await _controller.addMarker(
                        geoPoint,
                        markerIcon: MarkerIcon(
                          icon: Icon(
                            Icons.location_on,
                            color: theme.colorScheme.primary,
                            size: 48,
                          ),
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
                          markerIcon: MarkerIcon(
                            icon: Icon(
                              Icons.person_pin_circle,
                              color: theme.colorScheme.primary,
                              size: 56,
                            ),
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
                  top: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppStyles.styleMedium14.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for a place...',
                        hintStyle: AppStyles.styleRegular14.copyWith(
                          color: theme.hintColor,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        suffixIcon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _handleSearch(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120.h,
                  right: 16.w,
                  child: FloatingActionButton(
                    mini: true,
                    elevation: 4,
                    backgroundColor: theme.cardColor,
                    onPressed: () async {
                      try {
                        await _controller.currentLocation();
                        final point = await _controller.myLocation();
                        _updateAddress(point);
                      } catch (e) {
                        debugPrint('Error getting current location: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not get current location'),
                            ),
                          );
                        }
                      }
                    },
                    child: Icon(
                      Icons.my_location,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _address,
                          style: AppStyles.styleMedium14.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
    required this.onPressed,
  });
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: AppStyles.styleSemiBold16.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
