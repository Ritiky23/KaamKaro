import 'package:flutter/material.dart';
import 'package:kaamkaro/utils/location.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String cityName = '';
  double latitude = 0.0;
  double longitude = 0.0;

  void getLocation() async {
    getLoc location = getLoc();
    Map<String, dynamic> locationData = await location.getCurrentLocation();

    setState(() {
      cityName = locationData['city'];
      latitude = locationData['lat'];
      longitude = locationData['long'];
    });

    print("City: $cityName");
    print("Latitude: $latitude");
    print("Longitude: $longitude");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Latitude: $latitude',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Longitude: $longitude',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'City Name: $cityName',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getLocation,
              child: Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
