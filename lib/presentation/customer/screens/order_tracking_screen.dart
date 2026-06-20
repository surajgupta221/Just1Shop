// lib/presentation/customer/screens/order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/order_model.dart';
import '../../../core/services/location_service.dart';
import '../../../core/constants/ui_constants.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _deliveryBoyLocation;
  LatLng? _deliveryLocation;
  double _distance = 0;
  String _eta = 'Calculating...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    // Set delivery address as destination
    _deliveryLocation = LatLng(
      widget.order.deliveryAddress.latitude ?? 0,
      widget.order.deliveryAddress.longitude ?? 0,
    );

    // Listen for delivery boy location updates
    _listenToDeliveryBoyLocation();
    setState(() => _isLoading = false);
  }

  void _listenToDeliveryBoyLocation() {
    if (widget.order.deliveryBoyId == null) return;

    FirebaseFirestore.instance
        .collection('delivery_partners')
        .doc(widget.order.deliveryBoyId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final lat = data?['currentLatitude'] as double?;
        final lng = data?['currentLongitude'] as double?;

        if (lat != null && lng != null && _deliveryLocation != null) {
          setState(() {
            _deliveryBoyLocation = LatLng(lat, lng);
            _updateMapMarkers();
            _updateRouteLine();
            _calculateDistance();
          });
        }
      }
    });
  }

  void _updateMapMarkers() {
    _markers.clear();

    // Delivery boy marker (red)
    if (_deliveryBoyLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('delivery_boy'),
          position: _deliveryBoyLocation!,
          infoWindow: const InfoWindow(
            title: 'Delivery Boy',
            snippet: 'Current Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    // Destination marker (green)
    if (_deliveryLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _deliveryLocation!,
          infoWindow: InfoWindow(
            title: 'Delivery Address',
            snippet: widget.order.deliveryAddress.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
  }

  void _calculateDistance() {
    if (_deliveryBoyLocation != null && _deliveryLocation != null) {
      _distance = LocationService.calculateDistance(
        _deliveryBoyLocation!.latitude,
        _deliveryBoyLocation!.longitude,
        _deliveryLocation!.latitude,
        _deliveryLocation!.longitude,
      );

      _eta = LocationService.calculateETA(_distance);
    }
  }

  void _updateRouteLine() {
    _polylines.clear();
    if (_deliveryBoyLocation == null || _deliveryLocation == null) return;

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: [_deliveryBoyLocation!, _deliveryLocation!],
        width: 5,
        color: UIConstants.aiBlue,
      ),
    );
  }

  void _animateCameraToShowBoth() {
    if (_deliveryBoyLocation == null || _deliveryLocation == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _deliveryBoyLocation!.latitude < _deliveryLocation!.latitude
            ? _deliveryBoyLocation!.latitude
            : _deliveryLocation!.latitude,
        _deliveryBoyLocation!.longitude < _deliveryLocation!.longitude
            ? _deliveryBoyLocation!.longitude
            : _deliveryLocation!.longitude,
      ),
      northeast: LatLng(
        _deliveryBoyLocation!.latitude > _deliveryLocation!.latitude
            ? _deliveryBoyLocation!.latitude
            : _deliveryLocation!.latitude,
        _deliveryBoyLocation!.longitude > _deliveryLocation!.longitude
            ? _deliveryBoyLocation!.longitude
            : _deliveryLocation!.longitude,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Order Tracking'),
        backgroundColor: UIConstants.inkColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.smart_toy_outlined, color: UIConstants.aiBlue),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _updateMapMarkers();
                    _updateRouteLine();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _animateCameraToShowBoth();
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _deliveryLocation ??
                        const LatLng(20.5937, 78.9629), // India center
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),

                // Bottom info card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildTrackingInfo(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _animateCameraToShowBoth,
        backgroundColor: UIConstants.inkColor,
        child: const Icon(Icons.location_searching),
      ),
    );
  }

  Widget _buildTrackingInfo() {
    return Container(
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: UIConstants.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${widget.order.id.substring(0, 8)}',
                      style: UITextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.order.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_deliveryBoyLocation != null && _deliveryLocation != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_distance.toStringAsFixed(1)} km away',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: UIConstants.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ETA: $_eta',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Timeline
            _buildDeliveryTimeline(),
            const SizedBox(height: 16),

            // Call & Chat buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling delivery boy...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.inkColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeline() {
    return Column(
      children: [
        _buildTimelineItem(
          title: 'Order Placed',
          subtitle: _formatDate(widget.order.orderDate),
          isCompleted: true,
        ),
        _buildTimelineItem(
          title: 'Confirmed',
          subtitle: 'Restaurant confirmed order',
          isCompleted: widget.order.status != 'placed',
        ),
        _buildTimelineItem(
          title: 'On the Way',
          subtitle: _distance > 0
              ? '${_distance.toStringAsFixed(1)} km away'
              : 'Delivery boy arriving',
          isCompleted: widget.order.status == 'on_the_way' ||
              widget.order.status == 'delivered',
          isActive: widget.order.status == 'on_the_way',
        ),
        _buildTimelineItem(
          title: 'Delivered',
          subtitle: widget.order.status == 'delivered'
              ? _formatDate(widget.order.deliveryDate ?? DateTime.now())
              : 'Arriving soon',
          isCompleted: widget.order.status == 'delivered',
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.orange
                    : isCompleted
                        ? Colors.green
                        : Colors.grey[300],
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (isActive)
              Container(
                width: 2,
                height: 30,
                color: Colors.orange,
              ),
            if (!isActive && (isCompleted || true))
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.orange : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.order.status) {
      case 'placed':
        return Colors.blue;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'on_the_way':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}';
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
