// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ConstWithoutPolylineMap extends StatefulWidget {
//   final double? height;
//   final ValueChanged<String>? onAddressFetched;
//   final ValueChanged<LatLng>? onLatLngFetched;
//   final bool backIconAllowed;
//   final bool isLightMode;
//
//   const ConstWithoutPolylineMap({
//     super.key,
//     this.height,
//     this.onAddressFetched,
//     this.onLatLngFetched,  this.backIconAllowed = true,  this.isLightMode = false,
//   });
//
//   @override
//   State<ConstWithoutPolylineMap> createState() => _ConstWithoutPolylineMapState();
// }
//
// class _ConstWithoutPolylineMapState extends State<ConstWithoutPolylineMap> {
//   GoogleMapController? mapController;
//   final LatLng _initialPosition = LatLng(26.8467, 80.9462);
//   LatLng? _currentPosition;
//   Marker? _currentLocationMarker;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition();
//     _currentPosition = LatLng(position.latitude, position.longitude);
//
//     // _currentLocationMarker = Marker(
//     //   markerId: MarkerId("currentLocation"),
//     //   position: _currentPosition!,
//     //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//     // );
//
//     // Pass the LatLng back to the parent widget
//     widget.onLatLngFetched?.call(_currentPosition!);
//
//     setState(() {});
//
//     _fetchAddress(position.latitude, position.longitude);
//
//     if (mapController != null) {
//       mapController!.animateCamera(CameraUpdate.newCameraPosition(
//         CameraPosition(target: _currentPosition!, zoom: 15),
//       ));
//     }
//   }
//
//   Future<void> _fetchAddress(double latitude, double longitude) async {
//     const String apiKey = 'AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM';
//     final url =
//         'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
//
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['results'] != null && data['results'].isNotEmpty) {
//           final address = data['results'][0]['formatted_address'];
//           widget.onAddressFetched?.call(address);
//         }
//       } else {
//         if (kDebugMode) {
//           print('Failed to fetch address: ${response.statusCode}');
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error fetching address: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         SizedBox(
//           height: widget.height ?? MediaQuery.of(context).size.height,
//           child: GoogleMap(
//             liteModeEnabled: widget.isLightMode,
//             onMapCreated: (GoogleMapController controller) {
//               mapController = controller;
//               if (_currentPosition != null) {
//                 mapController!.animateCamera(CameraUpdate.newCameraPosition(
//                   CameraPosition(target: _currentPosition!, zoom: 15),
//                 ));
//               }
//             },
//             initialCameraPosition: CameraPosition(
//               target: _initialPosition,
//               zoom: 10,
//             ),
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             zoomControlsEnabled: false,
//             markers: _currentLocationMarker != null
//                 ? {_currentLocationMarker!}
//                 : {},
//           ),
//         ),
//         if(widget.backIconAllowed)
//           Positioned(
//             top: 40.0,
//             left: 10.0,
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 padding: EdgeInsets.all(8.0),
//                 child: Icon(
//                   Icons.arrow_back,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ConstWithoutPolylineMap extends StatefulWidget {
  final double? height;
  final ConstMapController controller;
  final ValueChanged<String>? onAddressFetched;
  final ValueChanged<LatLng>? onLatLngFetched;
  final bool backIconAllowed;

  const ConstWithoutPolylineMap({
    super.key,
    this.height,
    required this.controller,
    this.onAddressFetched,
    this.onLatLngFetched,
    this.backIconAllowed = true,
  });

  @override
  State<ConstWithoutPolylineMap> createState() => _ConstWithoutPolylineMapState();
}

class _ConstWithoutPolylineMapState extends State<ConstWithoutPolylineMap> {
  final LatLng _initialPosition = const LatLng(26.8467, 80.9462);
  BitmapDescriptor? currentIcon;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadMarkerIcon();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.addListener(_refresh);
    });
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _loadMarkerIcon() async {
    currentIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }

  Future<void> _initLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final latLng = LatLng(position.latitude, position.longitude);
    widget.onLatLngFetched?.call(latLng);

    widget.controller.updateMarker(
      Marker(markerId: const MarkerId("current"), position: latLng, icon: currentIcon!),
    );

    widget.controller.animateTo(latLng);
    _fetchAddress(position.latitude, position.longitude);
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    // your API fetch code here ...
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.height ?? MediaQuery.of(context).size.height,
          child: GoogleMap(
            liteModeEnabled: widget.controller.isLightMode,
            onMapCreated: (c) => widget.controller.attach(c),
            initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 10),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            markers: widget.controller.markers,
          ),
        ),

        if (widget.backIconAllowed)
          Positioned(
            top: 40,
            left: 10,
            child: _buildBackButton(),
          ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }
}


class ConstMapController extends ChangeNotifier {
  GoogleMapController? _gmController;
  Set<Marker> _markers = {};
  bool _lightMode = false;

  Set<Marker> get markers => _markers;
  bool get isLightMode => _lightMode;

  void attach(GoogleMapController controller) {
    _gmController = controller;
  }

  void toggleLightMode(bool value) {
    _lightMode = value;
    notifyListeners();
  }

  void updateMarker(Marker marker) {
    _markers.removeWhere((m) => m.markerId == marker.markerId);
    _markers.add(marker);
    notifyListeners();
  }

  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void animateTo(LatLng target, {double zoom = 15}) {
    _gmController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)),
    );
  }
}
