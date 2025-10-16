// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// //
// // class ConstMap extends StatefulWidget {
// //   final double? height;
// //   final ValueChanged<String>? onAddressFetched;
// //   final List<Map<String, dynamic>>? data;
// //   const ConstMap({super.key, this.height, this.onAddressFetched,this.data,});
// //
// //   @override
// //   State<ConstMap> createState() => _ConstMapState();
// // }
// //
// // class _ConstMapState extends State<ConstMap> {
// //   GoogleMapController? mapController;
// //   final LatLng _initialPosition = LatLng(26.8467, 80.9462);
// //   LatLng? _currentPosition;
// //   Marker? _currentLocationMarker;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _getCurrentLocation();
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     bool serviceEnabled;
// //     LocationPermission permission;
// //
// //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       return;
// //     }
// //
// //     permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         return;
// //       }
// //     }
// //
// //     if (permission == LocationPermission.deniedForever) {
// //       return;
// //     }
// //
// //     Position position = await Geolocator.getCurrentPosition();
// //     _currentPosition = LatLng(position.latitude, position.longitude);
// //
// //     _currentLocationMarker = Marker(
// //       markerId: MarkerId("currentLocation"),
// //       position: _currentPosition!,
// //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
// //     );
// //
// //     setState(() {});
// //
// //     _fetchAddress(position.latitude, position.longitude);
// //
// //     if (mapController != null) {
// //       mapController!.animateCamera(CameraUpdate.newCameraPosition(
// //         CameraPosition(target: _currentPosition!, zoom: 15),
// //       ));
// //     }
// //   }
// //
// //   Future<void> _fetchAddress(double latitude, double longitude) async {
// //     const String apiKey = 'AIzaSyCOqfJTgg1Blp1GIeh7o8W8PC1w5dDyhWI';
// //     final url =
// //         'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
// //
// //     try {
// //       final response = await http.get(Uri.parse(url));
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['results'] != null && data['results'].isNotEmpty) {
// //           final address = data['results'][0]['formatted_address'];
// //           widget.onAddressFetched?.call(address);
// //         }
// //       } else {
// //         if (kDebugMode) {
// //           print('Failed to fetch address: ${response.statusCode}');
// //         }
// //       }
// //     } catch (e) {
// //       if (kDebugMode) {
// //         print('Error fetching address: $e');
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Stack(
// //       children: [
// //         Container(
// //           height: widget.height ?? MediaQuery.of(context).size.height,
// //           child: GoogleMap(
// //             onMapCreated: (GoogleMapController controller) {
// //               mapController = controller;
// //               if (_currentPosition != null) {
// //                 mapController!.animateCamera(CameraUpdate.newCameraPosition(
// //                   CameraPosition(target: _currentPosition!, zoom: 15),
// //                 ));
// //               }
// //             },
// //             initialCameraPosition: CameraPosition(
// //               target: _initialPosition,
// //               zoom: 10,
// //             ),
// //             myLocationEnabled: true,
// //             myLocationButtonEnabled: true,
// //             zoomControlsEnabled: false,
// //             markers: _currentLocationMarker != null
// //                 ? {_currentLocationMarker!}
// //                 : {},
// //           ),
// //         ),
// //         // Positioned(
// //         //   top: 40.0,
// //         //   left: 10.0,
// //         //   child: GestureDetector(
// //         //     onTap: () {
// //         //       Navigator.of(context).pop();
// //         //     },
// //         //     child: Container(
// //         //       decoration: BoxDecoration(
// //         //         shape: BoxShape.circle,
// //         //         color: Colors.white,
// //         //         boxShadow: [
// //         //           BoxShadow(
// //         //             color: Colors.black.withOpacity(0.2),
// //         //             spreadRadius: 2,
// //         //             blurRadius: 5,
// //         //             offset: Offset(0, 3),
// //         //           ),
// //         //         ],
// //         //       ),
// //         //       padding: EdgeInsets.all(8.0),
// //         //       child: Icon(
// //         //         Icons.arrow_back,
// //         //         color: Colors.black,
// //         //       ),
// //         //     ),
// //         //   ),
// //         // ),
// //       ],
// //     );
// //   }
// // }
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ConstMap extends StatefulWidget {
//   final double? height;
//   final ValueChanged<String>? onAddressFetched;
//   final List<Map<String, dynamic>>? data; // expects list with pickup & drop
//   const ConstMap({super.key, this.height, this.onAddressFetched, this.data});
//
//   @override
//   State<ConstMap> createState() => _ConstMapState();
// }
//
// class _ConstMapState extends State<ConstMap> {
//   GoogleMapController? mapController;
//   final LatLng _initialPosition = LatLng(26.8467, 80.9462);
//   LatLng? _currentPosition;
//   Marker? _currentLocationMarker;
//
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//
//   @override
//   void initState() {
//     super.initState();
//     // _getCurrentLocation();
//     _addBookingMarkersAndPolyline();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//
//     if (permission == LocationPermission.deniedForever) return;
//
//     Position position = await Geolocator.getCurrentPosition();
//     _currentPosition = LatLng(position.latitude, position.longitude);
//
//     _currentLocationMarker = Marker(
//       markerId: MarkerId("currentLocation"),
//       position: _currentPosition!,
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       infoWindow: InfoWindow(title: "You are here"),
//     );
//
//     setState(() {
//       _markers.add(_currentLocationMarker!);
//     });
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
//     const String apiKey = 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA';
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
//       if (kDebugMode) print('Error fetching address: $e');
//     }
//   }
//
//   /// Convert address to LatLng
//   Future<LatLng?> _getLatLngFromAddress(String address) async {
//     try {
//       List<Location> locations = await locationFromAddress(address);
//       if (locations.isNotEmpty) {
//         return LatLng(locations.first.latitude, locations.first.longitude);
//       }
//     } catch (e) {
//       if (kDebugMode) print('Error converting address to LatLng: $e');
//     }
//     return null;
//   }
//
//   /// Add markers for pickup & drop and draw polyline
//   Future<void> _addBookingMarkersAndPolyline() async {
//     if (widget.data == null || widget.data!.isEmpty) return;
//
//     for (var booking in widget.data!) {
//       LatLng? pickupLatLng;
//       LatLng? dropLatLng;
//
//       // If lat/lng available use them, else convert from address
//       if (booking['pickup_latitute'] != null && booking['pick_longitude'] != null) {
//         pickupLatLng = LatLng(
//             booking['pickup_latitute'].toDouble(), booking['pick_longitude'].toDouble());
//       } else if (booking['pickup_address'] != null) {
//         pickupLatLng =
//         await _getLatLngFromAddress(booking['pickup_address'].toString());
//       }
//
//       if (booking['drop_latitute'] != null && booking['drop_logitute'] != null) {
//         dropLatLng =
//             LatLng(booking['drop_latitute'].toDouble(), booking['drop_logitute'].toDouble());
//       } else if (booking['drop_address'] != null) {
//         dropLatLng =
//         await _getLatLngFromAddress(booking['drop_address'].toString());
//       }
//
//       if (pickupLatLng != null) {
//         _markers.add(Marker(
//           markerId: MarkerId("pickup_${booking['id']}"),
//           position: pickupLatLng,
//           infoWindow: InfoWindow(title: "Pickup"),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ));
//       }
//
//       if (dropLatLng != null) {
//         _markers.add(Marker(
//           markerId: MarkerId("drop_${booking['id']}"),
//           position: dropLatLng,
//           infoWindow: InfoWindow(title: "Drop"),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ));
//       }
//
//       if (pickupLatLng != null && dropLatLng != null) {
//         _polylines.add(Polyline(
//           polylineId: PolylineId("route_${booking['id']}"),
//           points: [pickupLatLng, dropLatLng],
//           color: Colors.blue,
//           width: 5,
//         ));
//       }
//     }
//
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: widget.height ?? MediaQuery.of(context).size.height,
//       child: GoogleMap(
//         onMapCreated: (GoogleMapController controller) {
//           mapController = controller;
//           if (_currentPosition != null) {
//             mapController!.animateCamera(CameraUpdate.newCameraPosition(
//               CameraPosition(target: _currentPosition!, zoom: 12),
//             ));
//           }
//         },
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 10,
//         ),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         zoomControlsEnabled: false,
//         markers: _markers,
//         polylines: _polylines,
//       ),
//     );
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yoyomiles_partner/res/constant_color.dart';

class ConstMap extends StatefulWidget {
  final double? height;
  final ValueChanged<String>? onAddressFetched;
  final List<Map<String, dynamic>>? data; // expects list with pickup & drop

  const ConstMap({super.key, this.height, this.onAddressFetched, this.data});

  @override
  State<ConstMap> createState() => _ConstMapState();
}

class _ConstMapState extends State<ConstMap> {
  GoogleMapController? mapController;
  final LatLng _initialPosition = LatLng(26.8467, 80.9462);
  LatLng? _currentPosition;
  Marker? _currentLocationMarker;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addBookingMarkersAndPolyline();
  }

  /// Get current device location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);

    _currentLocationMarker = Marker(
      markerId: MarkerId("currentLocation"),
      position: _currentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: "You are here"),
    );

    setState(() {
      _markers.add(_currentLocationMarker!);
    });

    _fetchAddress(position.latitude, position.longitude);

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 15),
      ));
    }
  }

  /// Fetch address from latitude & longitude
  Future<void> _fetchAddress(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

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

  /// Fetch route points from Google Directions API
  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final polyline = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(polyline);
      }
    }
    return [];
  }

  /// Decode Google Polyline string
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }

  /// Add markers & draw route polylines for all bookings
  Future<void> _addBookingMarkersAndPolyline() async {
    if (widget.data == null || widget.data!.isEmpty) return;

    for (var booking in widget.data!) {
      LatLng? pickupLatLng;
      LatLng? dropLatLng;

      // Pickup LatLng
      if (booking['pickup_latitute'] != null && booking['pick_longitude'] != null) {
        pickupLatLng = LatLng(
          booking['pickup_latitute'].toDouble(),
          booking['pick_longitude'].toDouble(),
        );
      } else if (booking['pickup_address'] != null) {
        pickupLatLng = await _getLatLngFromAddress(booking['pickup_address'].toString());
      }

      // Drop LatLng
      if (booking['drop_latitute'] != null && booking['drop_logitute'] != null) {
        dropLatLng = LatLng(
          booking['drop_latitute'].toDouble(),
          booking['drop_logitute'].toDouble(),
        );
      } else if (booking['drop_address'] != null) {
        dropLatLng = await _getLatLngFromAddress(booking['drop_address'].toString());
      }

      // Add pickup marker
      if (pickupLatLng != null) {
        _markers.add(Marker(
          markerId: MarkerId("pickup_${booking['id']}"),
          position: pickupLatLng,
          infoWindow: InfoWindow(title: "Pickup"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      }

      // Add drop marker
      if (dropLatLng != null) {
        _markers.add(Marker(
          markerId: MarkerId("drop_${booking['id']}"),
          position: dropLatLng,
          infoWindow: InfoWindow(title: "Drop"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      }

      // Draw routed polyline
      if (pickupLatLng != null && dropLatLng != null) {
        List<LatLng> routePoints = await _getRoutePoints(pickupLatLng, dropLatLng);
        if (routePoints.isNotEmpty) {
          _polylines.add(Polyline(
            polylineId: PolylineId("route_${booking['id']}"),
            points: routePoints,
            color: PortColor.gold,
            width: 5,
          ));
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          if (_currentPosition != null) {
            mapController!.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentPosition!, zoom: 12),
            ));
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
