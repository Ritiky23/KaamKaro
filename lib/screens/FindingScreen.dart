import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:kaamkaro/screens/ChoosenUserScreen.dart';

class GeoUtils {
  static const double earthRadius = 6371.0; // Earth radius in kilometers

  static double calculateHaversine(double lat1,double lon1,double lat2,double lon2){
    print('worlat-${lat1}');
    print('worlong-${lon1}');
    print('reclat-${lat2}');
    print('reclong-${lon2}');
  var p = 0.017453292519943295;
  var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
        cos(lat1 * p) * cos(lat2 * p) * 
        (1 - cos((lon2 - lon1) * p))/2;
  double distance= 12742*asin(sqrt(a));
  print(distance);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFcbc0ff),
        title: Text(
            'Workers List',
            style: GoogleFonts.bebasNeue(
              textStyle: TextStyle(
                fontSize: 20.0, // Adjust the size as needed
                color: Colors.white,
                letterSpacing: 2.0,
                
              ),),),
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
  elevation: 1,
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: ListTile(
    contentPadding: EdgeInsets.all(16),
    leading: CircleAvatar(
      radius: 30,
      backgroundImage: AssetImage("images/work1.jpg"), // Replace with the actual path to your image
    ),
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
            Row(
              children: [
                Icon(Icons.location_on,size: 20,),
                Text(' ${user.city}'),
              ],
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right:53.0),
              child: Row(
                children: [
                  Icon(Icons.social_distance,size: 20,),
                  Text('  ${GeoUtils.calculateHaversine(worlat, worlong, reclat, reclong).toStringAsFixed(2)}km',),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
    onTap: () {
      // Navigate to the user's profile screen when tapped
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(wuid: user.wuid),
        ),
      );
    },
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
