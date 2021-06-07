import 'package:flutter/material.dart';
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
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (controller) => _googleMapController = controller,
        markers: {
          if (_origin != null) _origin!,
          if (_destination != null) _destination!,
        },
        onLongPress: _addMarker,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.center_focus_strong),
        onPressed: () async {
          return _googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(_initialCameraPosition),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
      ),
    );
  }

  void _addMarker(LatLng pos) {
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
        // reset destination

        _destination = null;
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
    }
  }
}
