import 'package:flutter/material.dart';
import 'package:flutter_maps/controller/directions_repository.dart';
import 'package:flutter_maps/models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(23.777176, 90.399452),
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Maps'),
        centerTitle: false,
        actions: [
          if (_origin != null)
            TextButton(
              child: Text(
                'Origin',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                return _googleMapController!
                    .animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin!.position,
                    zoom: 14,
                    tilt: 50,
                  ),
                ));
              },
            ),
          if (_destination != null)
            TextButton(
              child: Text(
                'Destination',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                return _googleMapController!
                    .animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination!.position,
                    zoom: 14,
                    tilt: 50,
                  ),
                ));
              },
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_info != null)
            Positioned(
              top: 50.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Text(
                  "${_info!.totalDistance}, ${_info!.totalDuration}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            onLongPress: _addMarker,
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.center_focus_strong),
        onPressed: () async {
          return _googleMapController!.animateCamera(
            _info != null
                ? CameraUpdate.newLatLngBounds(_info!.bounds, 100)
                : CameraUpdate.newCameraPosition(_initialCameraPosition),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // origin not set OR origin/destination are both set
      // set origin
      setState(() {
        _origin = Marker(
          markerId: MarkerId('origin'),
          infoWindow: InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );

        // Reset Destination
        _destination = null;

        // Reset Info
        _info = null;
      });
    } else {
      // origin is already set
      // set destination
      setState(() {
        _destination = Marker(
          markerId: MarkerId('destination'),
          infoWindow: InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      // Get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin!.position, destination: pos);
      setState(() {
        _info = directions;
      });
    }
  }
}
