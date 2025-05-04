import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class WeatherService{

  static Future<Weather?> getWeather(double lat , double lon) async {
    WeatherFactory wf = WeatherFactory("685412b0e894634b389316b68ed16693", language: Language.ENGLISH);
    try {
      Weather? weather = await wf.currentWeatherByLocation(lat, lon);
      return weather;
    } catch (e) {
      print('Error fetching weather data: $e');
      return null; // Handle error appropriately
    }
  }

  static Future<Position?> getCurrentLocation() async {
    LocationPermission permission;

    // Check if location services are enabled
    // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Prompt user to enable location
    //   await Geolocator.openLocationSettings();
    //   return Future.error('Location services are disabled.');
    // }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    // If all checks pass, get the current position
    return await Geolocator.getCurrentPosition(
     locationSettings:locationSettings
    );
  }
}