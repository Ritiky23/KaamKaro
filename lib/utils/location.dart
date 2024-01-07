import 'dart:developer';
import 'dart:ffi';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class getLoc{
Future<Map<String, dynamic>> getCurrentLocation()async{
  String cityName='';
  double lat=0;
  double long=0;
  LocationPermission permission=await Geolocator.checkPermission();
  getLoc location=getLoc();
  if(permission==LocationPermission.denied || permission==LocationPermission.deniedForever){
    log("Location Denied");
    LocationPermission ask=await Geolocator.requestPermission();
  }
  else{
    Position currentposition=await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    log("Latitude=${currentposition.latitude.toString()}");
    log("Latitude=${currentposition.longitude.toString()}");

    List<Placemark> placemarks = await placemarkFromCoordinates(currentposition.latitude, currentposition.longitude);
    cityName = placemarks.first.subAdministrativeArea?? '';
    lat=currentposition.latitude;
    long=currentposition.longitude;
  }
   return{
    'city':cityName,
    'lat':lat,
    'long':long
   };
}
}