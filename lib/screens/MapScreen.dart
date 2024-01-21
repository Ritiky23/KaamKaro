import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaamkaro/screens/FindingScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final double startLat;
  final double startLong;
  final double endLat;
  final double endLong;
  final String? rCity;
  final String? rNumber;
  final String? rName;

  const MapScreen({
    required this.startLat,
    required this.startLong,
    required this.endLat,
    required this.endLong,
    required this.rCity,
    required this.rNumber,
    required this.rName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
    CircleAvatar dp = CircleAvatar(
    child: Icon(AntDesign.user),
    radius: 50,
  );

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFcac1ff),
        title: Text('Recruiter Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildProfileTab(),
      ),
    );
  }
 Widget buildProfileTab() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            // Handle avatar change/upload here
            // You can open a dialog, navigate to another screen, or show a bottom sheet
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              dp,
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.rName!,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.phone, color: const Color.fromARGB(255, 156, 155, 155)),
                ),
                const SizedBox(height: 10),
GestureDetector(
  onTap: () {
    _launchPhone(widget.rNumber!);
  },
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(20),
      color: Color(0xFFf7f7f8),
    ),
    padding: const EdgeInsets.all(10),
    child: Text(
      widget.rNumber!,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ),
  ),
),

              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.location_on_rounded,color: const Color.fromARGB(255, 145, 144, 144),),
                ),
                const SizedBox(height: 10),
  Container(
  decoration: BoxDecoration(
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.circular(20),
    color: Color(0xFFf7f7f8),
  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.rCity!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 40),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Add your icons/buttons here
          ],
        ),
        ElevatedButton(
          onPressed: () {
           openMaps();
          },
          style: ElevatedButton.styleFrom(
    primary:  const Color(0xFF4b5ebc), // Change this color as per your preference
  ),
          child: Text('Open Maps',style: TextStyle( color: Colors.white)),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

void _launchPhone(String? phoneNumber) async {
  if (phoneNumber != null) {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch phone call: $url');
    }
  } else {
    print('Phone number is null');
  }
}



  // Function to open Maps application
  Future<void> openMaps() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${widget.endLat},${widget.endLong}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch Maps');
    }
  }
}
