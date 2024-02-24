import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaamkaro/screens/FindingScreen.dart';
import 'package:kaamkaro/utils/ProfileImageRec.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';


class RecruiterHomeScreen extends StatefulWidget {
  const RecruiterHomeScreen({super.key});

  @override
  State<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
 final _auth = FirebaseAuth.instance;
 bool isAvailable = false;
  final _firestore=FirebaseFirestore.instance;
  CircleAvatar dp = CircleAvatar(
    backgroundImage: AssetImage("images/dp_mine.jpg"),
    radius: 50,
  );

  String name = "__";
  String phoneNumber = "__";
  String aadharNumber = "__";
  String email = "__";
  String city="__";
  String ruid="";
  String profile="";
  ProfilePictureRec _profilePictureRec = ProfilePictureRec();
    final _profileImageStreamController = StreamController<String?>.broadcast();
  Stream<String?> get profileImageStream => _profileImageStreamController.stream;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
      _profilePictureRec.imageStream.listen((imageUrl) {
      // Notify the UI about the updated image URL
      setState(() {
        profile = imageUrl ?? ""; // Assuming profile is a member variable
      });
    });

  }

  Future<void> fetchProfileData() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      late User _currentUser;// Replace 'YOUR_UID' with the actual user's UID
      User? user = _auth.currentUser;
      ruid=user!.uid;
      // Replace 'workers' with the actual collection name in your Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('recruiters').doc(user!.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        setState(() {
          name = data['name'] ?? "__";
          phoneNumber = data['number'] ?? "__";
          aadharNumber = data['adhaar'] ?? "__";
          email = data['email'] ?? "__";
          city=data['city'] ?? "__";
          profile=data['profileImage']??"";
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Disable going back to the login screen by pressing the back button
      return false;
    },
    child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _signOut();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
          backgroundColor: Color(0xFFcbc0ff),
          title: Text(
            'KaamKaro',
            style: GoogleFonts.bebasNeue(
              textStyle: TextStyle(
                fontSize: 30.0,
                color: Colors.white,
                letterSpacing: 5.0,
              ),
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(AntDesign.user),
              ),
              Tab(
                icon: Icon(AntDesign.find),
              ),
            ],
            indicatorColor: Color(0xFF4b5ebc),
            unselectedLabelColor: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            buildProfileTab(),
            buildFindTab(),        
          ],
        ),
      ),
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
            onTap: () async {
              // Call pickImage to open the image picker
              _profilePictureRec.pickImage(context);
            },
            child: StreamBuilder<String?>(
              stream: profileImageStream, // Use the stream here
              initialData: profile,
              builder: (context, snapshot) {
                print('Snapshot: $snapshot');
                String? updatedProfile = snapshot.data;
                print('update::::${updatedProfile}');
                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: (profile != null && profile.isNotEmpty)
                          ? Image.network(
                              profile,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Color.fromARGB(255, 221, 214, 255),
                              child: const Icon(AntDesign.user, size: 50, color: Colors.white),
                            ),
                    ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFcbc0ff),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  },
),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.grey),
            const SizedBox(width: 4),
            Text(city),
          ],
        ),
        const SizedBox(height: 20),
        buildProfileCard(),
      ],
    ),
  );
}


  Widget buildProfileCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Color.fromARGB(255, 240, 240, 240),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildDataRow(Icons.phone, "Phone Number :", phoneNumber),
            const Divider(),
            buildDataRow(Icons.credit_card, "Aadhaar Number :", aadharNumber),
            const Divider(),
            buildDataRow(Icons.email, "Email :", email),
          ],
        ),
      ),
    );
  }

  Widget buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFindTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          SizedBox(height: 50,),
          buildIconButton("Labour", 'images/labour.png'),
          SizedBox(height: 20,),
          buildIconButton("Plumber", 'images/plumber.png'),
          SizedBox(height: 20,),
          buildIconButton("Carpenter", 'images/carpenter.png'),
          SizedBox(height: 20,),
          buildIconButton("Cleaner", 'images/cleaner.png'),
        ],
      ),
    );
  }

 Widget buildIconButton(String title, String imagePath) {
    return GestureDetector(
     onTap: () {
      showLocationDialog(title);
    },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 50,
              width: 50,
              // You can replace this with your image path or network image
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

void showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    contentPadding: EdgeInsets.zero, // Remove default padding
    content: Container(
      width: 200, // Set custom width for the container
      padding: EdgeInsets.all(16), // Add padding to the container
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Add border radius
        color: Colors.white, // Optional: Set background color
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFcbc0ff),
          ),
          SizedBox(width: 16),
          Text(
            "LOADING",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


    void showLocationDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Dialog'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    showLoaderDialog(context);  // Close the dialog
                    // Get current location
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );
                    // Get location details using Geocoding
                    List<Placemark> placemarks =
                      await placemarkFromCoordinates(
                      position.latitude,
                      position.longitude,
                    );
                    String city = placemarks.first.subAdministrativeArea??  'Unknown City';
                    // Use the obtained location details as needed
                    print('Current Location: $position, City: $city');
                    updateRecruiterLocation(ruid, city, position.latitude, position.longitude,title);
                    
                  },
                  child: Text('Current Location'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    showManualLocationDialog();
                  },
                  child: Text('Enter Location Manually'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop(); // Close the screen
  }

  void showManualLocationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String manualLocation = '';
      return AlertDialog(
        title: Text('Enter Location Manually'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    manualLocation = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter location',
                  ),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog

              // Use manualLocation as needed (e.g., perform geocoding)
              print('Entered Location: $manualLocation');
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}

  void updateRecruiterLocation(String recruiterUid, String cityName, double latitude, double longitude,String title) async {
  try {
    await FirebaseFirestore.instance
        .collection('recruiters')
        .doc(recruiterUid)
        .update({
          'city': cityName,
          'lat': latitude,
          'long': longitude,
        });
        Navigator.pop(context);
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WorkersList(customParameter: title)));
    print('Recruiter location updated successfully.');
  } catch (e) {
    print('Error updating recruiter location: $e');
  }
}



}
