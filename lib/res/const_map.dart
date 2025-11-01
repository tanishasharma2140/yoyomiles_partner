import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';

class ConstMap extends StatefulWidget {
  final double? height;
  final ValueChanged<String>? onAddressFetched;
  final List<Map<String, dynamic>>? data;
  final int? rideStatus;

  const ConstMap({
    super.key,
    this.height,
    this.onAddressFetched,
    this.data,
    this.rideStatus,
  });

  @override
  State<ConstMap> createState() => _ConstMapState();
}

class _ConstMapState extends State<ConstMap> {
  GoogleMapController? mapController;
  final Completer<GoogleMapController> completer = Completer();
  final LatLng _initialPosition = LatLng(26.8467, 80.9462);
  LatLng? _currentPosition;
  Marker? _currentLocationMarker;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  static const String _mapsApiKey = 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(ConstMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rideStatus != widget.rideStatus ||
        oldWidget.data != widget.data) {
      _updatePolylinesBasedOnStatus();
    }
  }

  /// Move camera to fit polyline with bounds
  Future<void> moveCameraOnPolyline(List<LatLng> points) async {
    if (points.isEmpty) return;

    final GoogleMapController controller = await completer.future;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 30));
    } catch (e) {
      debugPrint("Error moving camera: $e");
      // fallback
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 14),
      );
    }
  }

  /// Get current device location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() async {
        _currentPosition = LatLng(position.latitude, position.longitude);

        _currentLocationMarker = Marker(
          markerId: const MarkerId("currentLocation"),
          position: _currentPosition!,
          icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(74, 74)),
            Assets.assetsHueCurrent,
          ),
          infoWindow: const InfoWindow(title: "You are here"),
        );

        _markers.add(_currentLocationMarker!);
      });

      _fetchAddress(position.latitude, position.longitude);
      _addBookingMarkers();

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 15),
        ));
      }
    } catch (e) {
      if (kDebugMode) print('Error getting current location: $e');
    }
  }

  /// Fetch address from latitude & longitude
  Future<void> _fetchAddress(double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_mapsApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          widget.onAddressFetched?.call(address);
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch address: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching address: $e');
    }
  }

  /// Convert address to LatLng
  Future<LatLng?> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      if (kDebugMode) print('Error converting address to LatLng: $e');
    }
    return null;
  }

  /// Fixed Polyline Decoding Function
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      // Latitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      // Longitude
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Fetch route points from Google Directions API
  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_mapsApiKey';

    try {
      if (kDebugMode) {
        print('🔄 Fetching route from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          print('📍 Directions API Response: ${data['status']}');
        }

        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final polyline = data['routes'][0]['overview_polyline']['points'];
          final decodedPoints = _decodePolyline(polyline);

          if (kDebugMode) {
            print('✅ Polyline decoded successfully. Points: ${decodedPoints.length}');
          }

          return decodedPoints;
        } else {
          if (kDebugMode) {
            print('❌ Directions API Error: ${data['status']}');
            print('❌ Error message: ${data['error_message']}');
          }
        }
      } else {
        if (kDebugMode) {
          print('❌ HTTP Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching route points: $e');
    }

    return [];
  }

  /// Update polylines based on ride status
  void _updatePolylinesBasedOnStatus() {
    if (widget.data == null || widget.data!.isEmpty) return;
    _drawPolylinesBasedOnStatus(widget.data!.first);
  }

  /// Draw polylines based on ride status
  Future<void> _drawPolylinesBasedOnStatus(Map<String, dynamic> booking) async {
    // Clear existing polylines
    setState(() {
      _polylines.clear();
    });

    if (widget.rideStatus == null) return;

    LatLng? pickupLatLng;
    LatLng? dropLatLng;

    // Get pickup coordinates
    if (booking['pickup_latitute'] != null && booking['pick_longitude'] != null) {
      pickupLatLng = LatLng(
        double.parse(booking['pickup_latitute'].toString()),
        double.parse(booking['pick_longitude'].toString()),
      );
    } else if (booking['pickup_address'] != null) {
      pickupLatLng = await _getLatLngFromAddress(booking['pickup_address'].toString());
    }

    // Get drop coordinates
    if (booking['drop_latitute'] != null && booking['drop_logitute'] != null) {
      dropLatLng = LatLng(
        double.parse(booking['drop_latitute'].toString()),
        double.parse(booking['drop_logitute'].toString()),
      );
    } else if (booking['drop_address'] != null) {
      dropLatLng = await _getLatLngFromAddress(booking['drop_address'].toString());
    }

    if (kDebugMode) {
      print("📍 Ride Status: ${widget.rideStatus}");
      print("📍 Current Position: $_currentPosition");
      print("📍 Pickup LatLng: $pickupLatLng");
      print("📍 Drop LatLng: $dropLatLng");
    }

    // ✅ STATUS 4: PICKUP TO DROP POLYLINE (Aapka specific requirement)
    if (widget.rideStatus == 4 && pickupLatLng != null && dropLatLng != null) {
      if (kDebugMode) {
        print("🎯 STATUS 4: Drawing Pickup → Drop Polyline");
      }

      List<LatLng> routeToDrop = await _getRoutePoints(pickupLatLng, dropLatLng);

      if (routeToDrop.isNotEmpty) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("pickup_to_drop_status_4"),
            points: routeToDrop,
            color: PortColor.buttonBlue, // Different color for status 4
            width: 3,
          ));
        });

        // ✅ USE moveCameraOnPolyline FUNCTION HERE
        await moveCameraOnPolyline(routeToDrop);
      }
    }

    // ✅ CURRENT LOCATION SE PICKUP TAK POLYLINE (Status 1-3)
    if (widget.rideStatus! <= 3 && _currentPosition != null && pickupLatLng != null) {
      if (kDebugMode) {
        print("🔄 Drawing Current Location → Pickup Polyline");
      }

      List<LatLng> routeToPickup = await _getRoutePoints(_currentPosition!, pickupLatLng);

      if (routeToPickup.isNotEmpty) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("driver_to_pickup"),
            points: routeToPickup,
            color: Colors.blue,
            width: 3,
          ));
        });

        // ✅ USE moveCameraOnPolyline FUNCTION HERE
        await moveCameraOnPolyline(routeToPickup);
      }
    }

    // ✅ PICKUP SE DROP TAK POLYLINE (Status 5+)
    if (widget.rideStatus! >= 5 && pickupLatLng != null && dropLatLng != null) {
      if (kDebugMode) {
        print("🔄 Drawing Pickup → Drop Polyline (Status 5+)");
      }

      List<LatLng> routeToDrop = await _getRoutePoints(pickupLatLng, dropLatLng);

      if (routeToDrop.isNotEmpty) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("pickup_to_drop"),
            points: routeToDrop,
            color: Colors.green,
            width: 3,
          ));
        });

        // ✅ USE moveCameraOnPolyline FUNCTION HERE
        await moveCameraOnPolyline(routeToDrop);
      }
    }

    if (widget.rideStatus! >= 5 && _currentPosition != null && dropLatLng != null) {
      if (kDebugMode) {
        print("🔄 Drawing Current Location → Drop Polyline (Optional)");
      }

      List<LatLng> routeToFinal = await _getRoutePoints(_currentPosition!, dropLatLng);

      if (routeToFinal.isNotEmpty) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("driver_to_drop"),
            points: routeToFinal,
            color: Colors.orange,
            width: 3,
            patterns: [PatternItem.dash(10), PatternItem.gap(5)],
          ));
        });

        // ✅ USE moveCameraOnPolyline FUNCTION HERE (Optional)
        await moveCameraOnPolyline(routeToFinal);
      }
    }
  }

  /// Fit map to show all points
  void _fitMapToPoints(List<LatLng> points) {
    if (mapController == null || points.isEmpty) return;

    LatLngBounds bounds = _createBounds(points);

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }


  Future<BitmapDescriptor> resizeMarkerIcon(String assetPath, int targetWidth) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();

    final ByteData? byteData =
    await fi.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  /// Create LatLngBounds from points
  LatLngBounds _createBounds(List<LatLng> points) {
    double? west, north, east, south;

    for (LatLng point in points) {
      west = west != null ? (point.longitude < west ? point.longitude : west) : point.longitude;
      east = east != null ? (point.longitude > east ? point.longitude : east) : point.longitude;
      south = south != null ? (point.latitude < south ? point.latitude : south) : point.latitude;
      north = north != null ? (point.latitude > north ? point.latitude : north) : point.latitude;
    }

    return LatLngBounds(
      southwest: LatLng(south ?? 0, west ?? 0),
      northeast: LatLng(north ?? 0, east ?? 0),
    );
  }

  /// Add booking markers
  Future<void> _addBookingMarkers() async {
    if (widget.data == null || widget.data!.isEmpty) return;

    for (var booking in widget.data!) {
      LatLng? pickupLatLng;
      LatLng? dropLatLng;

      // Pickup LatLng
      if (booking['pickup_latitute'] != null && booking['pick_longitude'] != null) {
        pickupLatLng = LatLng(
          double.parse(booking['pickup_latitute'].toString()),
          double.parse(booking['pick_longitude'].toString()),
        );
      } else if (booking['pickup_address'] != null) {
        pickupLatLng = await _getLatLngFromAddress(booking['pickup_address'].toString());
      }

      if (booking['drop_latitute'] != null && booking['drop_logitute'] != null) {
        dropLatLng = LatLng(
          double.parse(booking['drop_latitute'].toString()),
          double.parse(booking['drop_logitute'].toString()),
        );
      } else if (booking['drop_address'] != null) {
        dropLatLng = await _getLatLngFromAddress(booking['drop_address'].toString());
      }

      // Add pickup marker - BADA SIZE (64x64)
      if (pickupLatLng != null) {
        final pickupIcon = await resizeMarkerIcon(Assets.assetsCurrentLocation, 65);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId("pickup_${booking['id']}"),
              position: pickupLatLng!,
              infoWindow: const InfoWindow(title: "Pickup Location"),
              icon: pickupIcon,
            ),
          );
        });
      }

      if (dropLatLng != null) {
        final dropIcon = await resizeMarkerIcon(Assets.assetsDropLocation, 65);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId("drop_${booking['id']}"),
              position: dropLatLng!,
              infoWindow: const InfoWindow(title: "Drop Location"),
              icon: dropIcon,
            ),
          );
        });
      }
    }

    // Draw polylines after adding markers
    if (widget.data!.isNotEmpty) {
      _drawPolylinesBasedOnStatus(widget.data!.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          completer.complete(controller); // ✅ Completer ko complete karo

          // Refresh polylines when map is ready
          if (widget.data != null && widget.data!.isNotEmpty) {
            _drawPolylinesBasedOnStatus(widget.data!.first);
          }
        },
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 10,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}