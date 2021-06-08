import 'package:dio/dio.dart';
import 'package:flutter_maps/models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '.env.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  Dio dio = Dio();
  // DirectionsRepository({
  // required this.dio,
  // });

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': googleAPIKey,
      },
    );

    // check if response is success
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}
