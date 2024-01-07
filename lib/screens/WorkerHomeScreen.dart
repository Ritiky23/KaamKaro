import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  CircleAvatar dp = CircleAvatar(
    child: Icon(AntDesign.user),
    radius: 50,
  );

  String name = "__";
  String phoneNumber = "__";
  String aadharNumber = "__";
  String email = "__";
  bool isAvailable = false;
  String city="__";
  double rating = 4.5; // Replace with actual rating
  int totalWorkCount = 50; // Replace with actual total work count

  @override
  void initState() {
    super.initState();
    fetchProfileData();
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
          city=data['city'] ?? "__";
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
          backgroundColor: const Color(0xFFcac1ff),
          title: Image.asset(
            "images/kaamtitle.png",
            width: 180,
            height: 200,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Icon(AntDesign.user),
              ),
              Tab(
                child: Icon(AntDesign.tool),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildProfileTab(),
            const Center(child: Text('Work Fragment')),
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

      setState(() {
        isAvailable = !isAvailable;
      });
    }
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
                Container(
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
              ],
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
                    children: [Icon(Icons.star),
                    SizedBox(width: 10,),
                    Text(
                    rating.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),],
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
}
