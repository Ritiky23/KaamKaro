import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class GeoUtils {
  static const double earthRadius = 6371.0; // Earth radius in kilometers

  static double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  static double calculateHaversine(
      double lat1, double lon1, double lat2, double lon2) {
    final double dLat = degreesToRadians(lat2 - lat1);
    final double dLon = degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final double distance = earthRadius * c; // Distance in kilometers

    return distance;
  }
}

class UserList {
  final String name;
  final String phoneNumber;
  final String city;
  final double latitude;
  final double longitude;
  bool isBookingConfirmed = false;
  final String wuid;

  UserList({
    required this.name,
    required this.phoneNumber,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.isBookingConfirmed,
    required this.wuid,
  });
}

String recCity = '';
double reclat = 0.0;
double reclong = 0.0;
String worcity = '';
double worlat = 0.0;
double worlong = 0.0;
String prof = '';
String wuid = '';
bool sent = false;

class WorkersList extends StatefulWidget {
  final String customParameter;

  const WorkersList({Key? key, required this.customParameter}) : super(key: key);

  @override
  State<WorkersList> createState() => _WorkersListState();
}

class _WorkersListState extends State<WorkersList> {
  late Stream<List<UserList>> usersStream;

  @override
  void initState() {
    super.initState();
    usersStream = fetchUsersWithConditionsStream();
  }

  Stream<List<UserList>> fetchUsersWithConditionsStream() {
    try {
      bool isAvailableCondition = true;
      FirebaseAuth auth = FirebaseAuth.instance;
      recCity = '';
      reclat = 0.0;
      reclong = 0.0;
      User? user = auth.currentUser;
      DocumentReference<Map<String, dynamic>> recruiterRef =
          FirebaseFirestore.instance.collection('recruiters').doc(user!.uid);

      // Listen for changes to the recruiter's document
      Stream<DocumentSnapshot<Map<String, dynamic>>> recruiterStream =
          recruiterRef.snapshots();

      return recruiterStream.asyncMap((snapshot) async {
        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;
          recCity = userData['city'] ?? '';
          reclat = userData['lat'];
          reclong = userData['long'];
          print('User: $recCity, Lat: $reclat, Long: $reclong');
        } else {
          print('No data found for the specified UID');
        }

        String prof = widget.customParameter;
        Query<Map<String, dynamic>> query = FirebaseFirestore.instance
            .collection('workers')
            .where('profession', isEqualTo: prof)
            .where('available', isEqualTo: isAvailableCondition)
            .where('city', isEqualTo: recCity);

        // Listen for changes to the query results
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();

        List<UserList> userList = [];
        List<DocumentSnapshot<Map<String, dynamic>>> documents =
            querySnapshot.docs;
        for (DocumentSnapshot<Map<String, dynamic>> document in documents) {
          Map<String, dynamic> userData = document.data()!;
          String name = userData['name'] ?? '';
          String phoneNumber = userData['number'] ?? '';
          worcity = userData['city'] ?? '';
          worlat = userData['lat'];
          worlong = userData['long'];
          wuid = userData['uid'];

          userList.add(UserList(
            name: name,
            phoneNumber: phoneNumber,
            city: worcity,
            latitude: worlat,
            longitude: worlong,
            isBookingConfirmed: isAvailableCondition,
            wuid: wuid,
          ));
        }

        return userList;
      });
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
  }

  Future<void> sendRequestAndUpdateRecruiterData(String workerUid) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      String recuid = user!.uid;

      // Update the worker's document with the request
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerUid)
          .update({
        'requests.$recuid': false,
      });

      // Update the recruiter's document with the request ID and initial status as false
      await FirebaseFirestore.instance
          .collection('recruiters')
          .doc(user!.uid)
          .update({
        'requested.$workerUid': false, // Create a map entry with workerUid:false
      });

      // Display a success message or handle UI updates as needed
      print('Request sent successfully');
    } catch (e) {
      // Handle errors, such as network issues or Firestore write errors
      print('Error sending request: $e');
    }
  }

  Future<bool> isCurrentUserInWorkerRequests(String workerUid) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      DocumentSnapshot<Map<String, dynamic>> workerSnapshot =
          await FirebaseFirestore.instance.collection('workers').doc(workerUid).get();

      if (workerSnapshot.exists) {
        Map<String, dynamic> workerData = workerSnapshot.data()!;
        List<String> requests = List<String>.from(workerData['requests'] ?? []);

        // Check if the current user's ID is in the requests list
        return requests.contains(user?.uid);
      }

      return false; // Worker document doesn't exist
    } catch (e) {
      print('Error checking if current user is in worker requests: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workers List'),
      ),
      body: StreamBuilder<List<UserList>>(
        stream: usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<UserList> userList = snapshot.data!;
            return ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                UserList user = userList[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 4),
                            Text('City: ${user.city}'),
                            SizedBox(height: 4),
                            Text(
                              'Distance: ${GeoUtils.calculateHaversine(worlat, worlong, user.latitude, user.longitude).toStringAsFixed(2)} km',
                            ),
                          ],
                        ),
     ElevatedButton(
  onPressed: () async {
    // Check if the current recruiter's UID is in the worker's requests list
    bool isRecruiterInRequests =
        await isCurrentUserInWorkerRequests(user.wuid);
    if (isRecruiterInRequests) {
      setState(() {
        sent = false;
      });
    } else {
      setState(() {
        sent = true;
        sendRequestAndUpdateRecruiterData(user.wuid);
        print(sent);
      });
    }
  },
  child: Text(sent ? 'Waiting' : 'Book'),
),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
