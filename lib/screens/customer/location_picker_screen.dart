import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/models/delivery_address.dart';
import 'package:fresh_harvest/providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialAddress,
    this.isEditing = false,
  });

  final DeliveryAddress? initialAddress;
  final bool isEditing;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // ── State Variables ──────────────────────────────────────────────────────

  LatLng _selectedLocation = const LatLng(33.5651, 71.4421);
  GoogleMapController? _mapController;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;
  String _selectedAddressType = 'Home';
  final List<String> _addressTypes = ['Home', 'Work', 'Other'];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    
    if (widget.initialAddress != null) {
      _populateForm(widget.initialAddress!);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  // ── Initialization ──────────────────────────────────────────────────────────

  Future<void> _initializeLocation() async {
    if (widget.initialAddress != null) {
      setState(() {
        _selectedLocation = LatLng(
          widget.initialAddress!.latitude,
          widget.initialAddress!.longitude,
        );
      });
      return;
    }

    // Try to get current location
    setState(() => _isLoading = true);
    
    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        setState(() {
          _selectedLocation = LatLng(
            position.latitude,
            position.longitude,
          );
        });
        // Move camera to current location
        _animateToLocation(_selectedLocation);
      }
    } catch (e) {
      // Use default location if current location fails
      debugPrint('Could not get current location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog to enable location services
        if (mounted) {
          await _showLocationServiceDialog();
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showPermissionDeniedSnackBar();
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showPermissionDeniedForeverDialog();
        }
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // ── Form Methods ──────────────────────────────────────────────────────────

  void _populateForm(DeliveryAddress address) {
    _addressController.text = address.formatted;
    _streetController.text = address.street;
    _cityController.text = address.city;
    _areaController.text = address.area;
    _landmarkController.text = address.landmark ?? '';
    _selectedAddressType = address.label;
  }

  bool _validateForm() {
    if (_streetController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your street address');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your city');
      return false;
    }
    if (_areaController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your area');
      return false;
    }
    return true;
  }

  // ── Map Methods ────────────────────────────────────────────────────────────

  void _animateToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 17,
        ),
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    // Implement geocoding or location search here
    // For now, just show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location search coming soon!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // ── Save Location ──────────────────────────────────────────────────────────

  Future<void> _saveLocation() async {
    if (!_validateForm()) return;
    if (_selectedLocation == const LatLng(33.5651, 71.4421)) {
      _showErrorSnackBar('Please select a location on the map');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final address = DeliveryAddress(
        id: widget.isEditing && widget.initialAddress != null
            ? widget.initialAddress!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        label: _selectedAddressType,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
        formatted: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : '${_streetController.text.trim()}, ${_areaController.text.trim()}, ${_cityController.text.trim()}',
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );

      // Save to provider
      final locationProvider = context.read<LocationProvider>();
      
      if (widget.isEditing) {
        await locationProvider.updateAddress(address);
      } else {
        await locationProvider.addAddress(address);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Address updated successfully ✅'
                : 'Address saved successfully ✅',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context, address);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to save address: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  Future<void> _showLocationServiceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text('Open App Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permission is required to find your location'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Address' : 'Select Location',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location_rounded),
              onPressed: () async {
                final position = await _getCurrentLocation();
                if (position != null && mounted) {
                  setState(() {
                    _selectedLocation = LatLng(
                      position.latitude,
                      position.longitude,
                    );
                  });
                  _animateToLocation(_selectedLocation);
                }
              },
              tooltip: 'Use current location',
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Map ─────────────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (position) {
                    setState(() {
                      _selectedLocation = position;
                    });
                    // Update address hint with coordinates
                    _addressController.text =
                        'Lat: ${position.latitude.toStringAsFixed(6)}, '
                        'Lng: ${position.longitude.toStringAsFixed(6)}';
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() {
                          _selectedLocation = newPosition;
                        });
                        _addressController.text =
                            'Lat: ${newPosition.latitude.toStringAsFixed(6)}, '
                            'Lng: ${newPosition.longitude.toStringAsFixed(6)}';
                      },
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                ),
                // Center pin indicator
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red.shade700,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                // Zoom controls
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        onPressed: () {
                          _mapController?.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },
                        heroTag: 'zoom_in',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        child: const Icon(Icons.add_rounded, size: 24),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        onPressed: () {
                          _mapController?.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },
                        heroTag: 'zoom_out',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        child: const Icon(Icons.remove_rounded, size: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Address Form ──────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Address Type ─────────────────────────────────────────
                    Row(
                      children: [
                        const Text(
                          'Address Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ..._addressTypes.map((type) {
                          final isSelected = _selectedAddressType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedAddressType = type;
                                });
                              },
                              selectedColor: Colors.green.shade700,
                              backgroundColor: Colors.grey.shade100,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Form Fields ──────────────────────────────────────────
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Full Address (Optional)',
                        hintText: 'Tap on map to auto-fill',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(Icons.home_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _streetController,
                            decoration: const InputDecoration(
                              labelText: 'Street Address *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: Icon(Icons.streetview_rounded,
                                  size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _areaController,
                            decoration: const InputDecoration(
                              labelText: 'Area *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: Icon(Icons.location_city_rounded,
                                  size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: Icon(Icons.location_on_rounded,
                                  size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _landmarkController,
                            decoration: const InputDecoration(
                              labelText: 'Landmark (Optional)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: Icon(Icons.place_rounded, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Save Button ──────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Update Address'
                                    : 'Save Address',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}