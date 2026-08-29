import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/location_service.dart';
import 'market_comparison_screen.dart';

class MarketLocationPickerScreen extends StatefulWidget {
  final String commodityName;
  final String currentMarketName;
  final int? commodityId;
  final double? initialLat;
  final double? initialLng;
  final String? initialLabel;
  final bool isChangeMode;

  const MarketLocationPickerScreen({
    super.key,
    required this.commodityName,
    required this.currentMarketName,
    this.commodityId,
    this.initialLat,
    this.initialLng,
    this.initialLabel,
    this.isChangeMode = false,
  });

  @override
  State<MarketLocationPickerScreen> createState() => _MarketLocationPickerScreenState();
}

class _MarketLocationPickerScreenState extends State<MarketLocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _selectedLocation;
  String _locationLabel = 'Select location on map or detect GPS';
  bool _isGpsLoading = false;
  bool _isGeocoding = false;
  String? _gpsError;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Default to passed location, or Kerala central area (e.g. 9.5916, 76.5222)
    final double lat = widget.initialLat ?? 9.5916;
    final double lng = widget.initialLng ?? 76.5222;
    _selectedLocation = LatLng(lat, lng);

    if (widget.initialLabel != null && widget.initialLabel!.isNotEmpty) {
      _locationLabel = widget.initialLabel!;
    } else {
      _updateLocationLabel(lat, lng);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _updateLocationLabel(double lat, double lng) async {
    setState(() {
      _isGeocoding = true;
    });

    final label = await LocationService.reverseGeocode(lat, lng);

    if (mounted) {
      setState(() {
        _locationLabel = label;
        _isGeocoding = false;
      });
    }
  }

  Future<void> _handleDetectCurrentLocation() async {
    setState(() {
      _isGpsLoading = true;
      _gpsError = null;
    });

    try {
      final position = await LocationService.determinePosition();
      final target = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = target;
        _isGpsLoading = false;
      });

      _mapController.move(target, 12.0);
      await _updateLocationLabel(position.latitude, position.longitude);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Location detected: $_locationLabel')),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGpsLoading = false;
          _gpsError = e.toString().replaceFirst('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_gpsError ?? 'Failed to get GPS location'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _gpsError = null;
    });
    _updateLocationLabel(point.latitude, point.longitude);
  }

  void _handleConfirmLocation() {
    if (widget.isChangeMode) {
      // Pop back with chosen location
      Navigator.of(context).pop(
        UserLocationResult(
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
          label: _locationLabel,
        ),
      );
    } else {
      // Redirect to comparison results screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MarketComparisonScreen(
            commodityName: widget.commodityName,
            currentMarketName: widget.currentMarketName,
            commodityId: widget.commodityId,
            selectedLat: _selectedLocation.latitude,
            selectedLng: _selectedLocation.longitude,
            selectedLocationLabel: _locationLabel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isChangeMode ? 'Change Location' : 'Choose Your Location',
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${widget.commodityName} • Near ${widget.currentMarketName}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Detect GPS Action Banner
            _buildGpsDetectionCard(),

            // Map Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.pin_drop_rounded, size: 18, color: Color(0xFFF97316)),
                  const SizedBox(width: 6),
                  const Text(
                    'Or Drop Pin on Map',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap map to place pin',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFEA580C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Map View
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD8BF), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation,
                          initialZoom: 10.0,
                          minZoom: 4.0,
                          maxZoom: 18.0,
                          onTap: _onMapTapped,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.mandi_intelligence_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation,
                                width: 50,
                                height: 50,
                                child: _buildAnimatedPinMarker(),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Map Control overlay buttons (Zoom / GPS Recenter)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMapCircleButton(
                              icon: Icons.add,
                              tooltip: 'Zoom In',
                              onTap: () {
                                final currentZoom = _mapController.camera.zoom;
                                _mapController.move(_selectedLocation, currentZoom + 1);
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildMapCircleButton(
                              icon: Icons.remove,
                              tooltip: 'Zoom Out',
                              onTap: () {
                                final currentZoom = _mapController.camera.zoom;
                                _mapController.move(_selectedLocation, currentZoom - 1);
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildMapCircleButton(
                              icon: Icons.my_location,
                              tooltip: 'Center on Pin',
                              iconColor: const Color(0xFFF97316),
                              onTap: () {
                                _mapController.move(_selectedLocation, 12.0);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Confirmation Card
            _buildBottomConfirmationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPinMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildGpsDetectionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0CC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isGpsLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFF97316),
                    ),
                  )
                : const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFFF97316),
                    size: 22,
                  ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use Current Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Auto-detect your farm/mandi location via GPS',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isGpsLoading ? null : _handleDetectCurrentLocation,
            icon: const Icon(Icons.gps_fixed_rounded, size: 16),
            label: Text(
              _isGpsLoading ? 'Detecting...' : 'Detect',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF374151),
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location Details Display
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.place_rounded, color: Color(0xFFF97316), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECTED LOCATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _isGeocoding
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFF97316),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Resolving address...',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          )
                        : Text(
                            _locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                    Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Primary Confirmation / Compare Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFFF97316).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _handleConfirmLocation,
              icon: Icon(
                widget.isChangeMode ? Icons.check_circle_outline : Icons.compare_arrows_rounded,
                size: 20,
              ),
              label: Text(
                widget.isChangeMode ? 'Apply Location' : 'Compare Mandis for This Location',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
