import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaamkaro/screens/FindingScreen.dart';
import 'package:kaamkaro/screens/Locate.dart';
import 'package:kaamkaro/screens/MapScreen.dart';
import 'package:kaamkaro/screens/ReqPhoneMapScreen.dart';
import 'package:kaamkaro/screens/WorkerRecProfile.dart';
import 'package:kaamkaro/utils/ProfileImageWorker.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
CircleAvatar dp = CircleAvatar(
  backgroundImage: AssetImage("images/work1.jpg"),
  radius: 50,
);
  final _profileImageStreamController = StreamController<String?>.broadcast();
  Stream<String?> get profileImageStream => _profileImageStreamController.stream;
  String name = "__";
  String phoneNumber = "__";
  String aadharNumber = "__";
  String email = "__";
  String profile="";
  String recProfile="__";
  bool isAvailable = false;
  String city = "__";
  double rating = 4.5; // Replace with the actual rating
  int totalWorkCount = 50; // Replace with the actual total work count
  ProfilePictureWorker _profilePicture = ProfilePictureWorker();

  bool tickbtn = false;
  String recName = "";
  String recCity = "";
  double reclat = 0;
  double reclong = 0;
  String distance = "";
  String recNumber="";
  String recEmail="";
  List<GlobalKey> _keys = [];

@override
void initState() {
  super.initState();
  fetchProfileData();
  tickbtn = false;
  // Add a listener to the image stream in the ProfilePictureWorker
  _profilePicture.imageStream.listen((imageUrl) {
    // Notify the UI about the updated image URL
    setState(() {
      profile = imageUrl ?? ""; // Assuming profile is a member variable
    });
  });

  // Fetch the 'isAvailable' value and update the state
  fetchIsAvailable();
}

Future<void> fetchIsAvailable() async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('workers').doc(user!.uid).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      bool available = data['available'] ?? false;

      setState(() {
        isAvailable = available;
      });
    }
  } catch (e) {
    print('Error fetching isAvailable data: $e');
  }
}

 Future<void> fetchProfileData() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('workers').doc(user!.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        setState(() {
          name = data['name'] ?? "__";
          phoneNumber = data['number'] ?? "__";
          aadharNumber = data['adhaar'] ?? "__";
          email = data['email'] ?? "__";
          city = data['city'] ?? "__";
          profile = data['profileImage'] ?? "";
          // Add the following line to notify the UI about changes in the profile image URL
          _profileImageStreamController.add(profile);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
          backgroundColor: const Color(0xFFcac1ff),
          title:         Text(
            'KaamKaro',
            style: GoogleFonts.bebasNeue(
              textStyle: TextStyle(
                fontSize: 30.0, // Adjust the size as needed
                color: Colors.white,
                letterSpacing: 5.0,
                
              ),),),
          bottom: TabBar(
  tabs: [
    Tab(
      icon: Icon(AntDesign.user),
    ),
    Tab(
      icon: Icon(AntDesign.tool),
    ),
  ],
  indicatorColor: Color(0xFF4b5ebc),  // Color for the selected tab indicator
  unselectedLabelColor: Colors.white,  // Color for unselected tab icon
),

          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),),
        ),
        
        body: TabBarView(
          children: [
            buildProfileTab(),
            buildWorkTab(),
          ],
        ),
      ),
    );
  }

  Future<void> toggleAvailability() async {
    User? user = _auth.currentUser;
    if (user != null) {

      await _firestore.collection('workers').doc(user.uid).update({
        'available': !isAvailable,
      });
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('workers').doc(user?.uid).get();
    if (snapshot.exists) {
    Map<String, dynamic> data = snapshot.data()!;
    bool currentAvailability = data['available'] ?? false;
    // Update the UI based on the fetched availability value
    setState(() {
      isAvailable = currentAvailability;
    });
  }
    }}

Widget buildWorkTab() {
  return RefreshIndicator(
    onRefresh: () async {
      // Implement your actual refresh logic here
      await Future.delayed(Duration(seconds: 2)); // Simulating a delay
      setState(() {
        // Update your data here
        print('Data refreshed');
      });
    },
    child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('workers').doc(_auth.currentUser?.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        var workerData = snapshot.data!.data();
        if (workerData == null || !workerData.containsKey('requests')) {
          return Scaffold(
            body: Center(
              child: Text('No requests available'),
            ),
          );
        }

        var requestsData = workerData['requests'];
        if (requestsData == null || requestsData.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text('No requests available'),
            ),
          );
        }

        bool allRequestsTrue = requestsData.values.every((requestStatus) => requestStatus == true);

        if (allRequestsTrue) {
          return Scaffold(
            body: Center(
              child: Text('No requests available'),
            ),
          );
        }

        List<dynamic> keysWithFalseValue = requestsData.entries
            .where((entry) => entry.value == false)
            .map((entry) => entry.key)
            .toList();

        return ListView.builder(
          itemCount: keysWithFalseValue.length,
          itemBuilder: (context, index) {
            var recuid = keysWithFalseValue[index] as String;
             GlobalKey key = GlobalKey();
              _keys.add(key);
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('recruiters').doc(recuid).get(),
              builder: (context, recSnapshot) {
                if (!recSnapshot.hasData) {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 19, 19, 247),
                      ),
                    ),
                  );
                }

                var recData = recSnapshot.data!.data();
                if (recData == null) {
                  return Text('No data available for the recruiter');
                }

                return ListTile(
                  key: GlobalKey(),
                  leading: CircleAvatar(
                    radius: 30,
                    child: recData['profileImage'] != null && recData['profileImage'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              recData['profileImage'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            AntDesign.user,
                            size: 30,
                            color: Colors.white,
                          ),
                  ),
                  title: Text(
                    recData['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recData['city'],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${GeoUtils.calculateHaversine(worlat, worlong, recData['lat'], recData['long']).toStringAsFixed(2)}km',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: !tickbtn,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            removeRequest(recuid, key);
                            // Handle "Close" button click
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Visibility(
                        visible: !tickbtn,
                        child: IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              tickbtn = true;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneMapScreen(
                                  phoneNumber: recData['number'],
                                  recName: recData['name'],
                                  recProfile: recData['profileImage'],
                                  reclat: recData['lat'],
                                  reclong: recData['long'],
                                  worlat: worlat,
                                  worlong: worlong,
                                ),
                              ),
                            );
                            updateRequestStatus(recuid, true);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ),
  );
}

  void removeRequest(String recuid, GlobalKey key) {
    FirebaseFirestore.instance.collection('workers').doc(_auth.currentUser?.uid).update({
      'requests.$recuid': FieldValue.delete(),
    }).then((_) {
      setState(() {
        _keys.remove(key);
      });
    });
  }

 Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop(); // Close the screen
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
              _profilePicture.pickImage(context);
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
                              backgroundColor: Colors.grey,
                              child: const Icon(Icons.person, size: 50, color: Colors.white),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 10,),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    'Total Work',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    totalWorkCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: toggleAvailability,
            style: ElevatedButton.styleFrom(
              primary: isAvailable ? const Color(0xFF23c662) : const Color(0xFF4b5ebc),
            ),
            child: Text(
              isAvailable ? 'Mark as Unavailable' : 'Mark as Available',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateRequestStatus(String recuid, bool status) async {
    try {
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(_auth.currentUser?.uid)
          .update({
        'requests.$recuid': status,
      });
      print('Request status updated successfully');
    } catch (e) {
      print('Error updating request status: $e');
    }
  }
}
