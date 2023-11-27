import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0); // Posición inicial
  Set<Marker> _markers = {}; // Colección de marcadores

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // Solicitar permisos al inicio
  }

  void _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }

    _getLocation();
  }

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.clear(); // Limpiar marcadores anteriores
        _markers.add(Marker(
          markerId: MarkerId("current_location"),
          position: _currentPosition,
          infoWindow: InfoWindow(
            title: "Tu ubicación actual",
          ),
        ));
      });

      _animateCameraToPosition(_currentPosition);
    } catch (e) {
      print("Error obteniendo la ubicación: $e");
    }
  }

  void _animateCameraToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Screen'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        markers: _markers,
      ),
    );
  }
}
