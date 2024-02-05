import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaamkaro/screens/FindingScreen.dart';
import 'package:kaamkaro/screens/Locate.dart';

class PhoneMapScreen extends StatefulWidget {
  final String phoneNumber;
  final String recName;
  final String recProfile;
  final double reclat;
  final double reclong;
  final double worlat;
  final double worlong;

  const PhoneMapScreen({
    Key? key,
    required this.phoneNumber,
    required this.recName,
    required this.recProfile,
    required this.reclat,
    required this.reclong,
    required this.worlat,
    required this.worlong,
  }) : super(key: key);

  @override
  State<PhoneMapScreen> createState() => _PhoneMapScreenState();
}

class _PhoneMapScreenState extends State<PhoneMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFcac1ff),
        title: Text('Profile Details'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
      ),),
      body: Center(
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.recProfile),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.recName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Divider(), // Add a divider line
                SizedBox(height: 8),
                Text(
                  'Phone: ${widget.phoneNumber}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(
                          reclat,
                          reclong,
                                                  ),
                      ),
                    );
                  },
                  child: Text('Go to Map'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
