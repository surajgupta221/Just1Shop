// lib/presentation/delivery/screens/delivery_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/services/location_service.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String deliveryBoyId;
  final String orderId;
  final String customerName;
  final String deliveryAddress;

  const DeliveryTrackingScreen({
    Key? key,
    required this.deliveryBoyId,
    required this.orderId,
    required this.customerName,
    required this.deliveryAddress,
  }) : super(key: key);

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  late GoogleMapController _mapController;
  late LocationService _locationService;
  Position? _currentPosition;
  bool _isTrackingActive = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    try {
      // Check location permissions
      final permission = await _locationService.checkPermission;
      
      if (permission == LocationPermission.denied) {
        await _locationService.requestLocationPermission();
      }

      // Get current position
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      if (position != null) {
        _showSnackbar('Location tracking ready. Tap START DELIVERY when you begin.');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startTracking() async {
    setState(() => _isTrackingActive = true);
    
    try {
      await _locationService.shareLiveLocation(
        deliveryBoyId: widget.deliveryBoyId,
        orderId: widget.orderId,
      );
      _showSnackbar('✅ Live location sharing started!');
    } catch (e) {
      _showSnackbar('❌ Error starting tracking: $e');
      setState(() => _isTrackingActive = false);
    }
  }

  Future<void> _stopTracking() async {
    setState(() => _isTrackingActive = false);
    
    try {
      await _locationService.stopSharingLocation(widget.deliveryBoyId);
      _showSnackbar('Location sharing stopped');
    } catch (e) {
      _showSnackbar('Error stopping tracking: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        backgroundColor: UIConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                        : const LatLng(20.5937, 78.9629),
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  markers: {
                    if (_currentPosition != null)
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        infoWindow: const InfoWindow(
                          title: 'Your Location',
                        ),
                      ),
                  },
                ),

                // Top info card
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildDeliveryInfo(),
                ),

                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildControls(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
              ),
            );
          }
        },
        backgroundColor: UIConstants.primaryColor,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order: #${widget.orderId.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer: ${widget.customerName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isTrackingActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isTrackingActive ? 'LIVE' : 'OFFLINE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery To:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.deliveryAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current coordinates
            if (_currentPosition != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Main action button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isTrackingActive
                  ? ElevatedButton.icon(
                      onPressed: _stopTracking,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('STOP DELIVERY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _startTracking,
                      icon: const Icon(Icons.navigation),
                      label: const Text('START DELIVERY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outlined,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isTrackingActive
                          ? 'Your location is being shared with the customer'
                          : 'Start delivery to share your live location with customer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isTrackingActive) {
      _stopTracking();
    }
    _mapController.dispose();
    super.dispose();
  }
}
