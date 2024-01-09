import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double startLat;
  final double startLong;
  final double endLat;
  final double endLong;

  const MapScreen({
    required this.startLat,
    required this.startLong,
    required this.endLat,
    required this.endLong,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Map'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.startLat, widget.startLong),
          zoom: 12.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('start'),
            position: LatLng(widget.startLat, widget.startLong),
            infoWindow: InfoWindow(title: 'Start Location'),
          ),
          Marker(
            markerId: MarkerId('end'),
            position: LatLng(widget.endLat, widget.endLong),
            infoWindow: InfoWindow(title: 'End Location'),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: [
              LatLng(widget.startLat, widget.startLong),
              LatLng(widget.endLat, widget.endLong),
            ],
            color: Colors.blue,
            width: 4,
          ),
        },
      ),
    );
  }
}