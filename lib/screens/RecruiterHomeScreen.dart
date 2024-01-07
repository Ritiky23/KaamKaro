import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaamkaro/screens/FindingScreen.dart';




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
    child: Icon(AntDesign.user),
    radius: 50,
  );

  String name = "__";
  String phoneNumber = "__";
  String aadharNumber = "__";
  String email = "__";
  String city="__";

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      late User _currentUser;// Replace 'YOUR_UID' with the actual user's UID
      User? user = _auth.currentUser;
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
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  Future<void> fetchUsersWithConditions() async {
  try {
    // Define the conditions
    bool isAvailableCondition = true;  // Replace with your actual condition // Replace with your actual condition
    FirebaseAuth auth=FirebaseAuth.instance;
    String recCity = '';
    String reclat = '';
    String reclong = '';
    User? user=auth.currentUser;
    DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('recruiters').doc(user!.uid).get();
        if (snapshot.exists) {
      // Document exists, process the data
      Map<String, dynamic> userData = snapshot.data()!;
      recCity = userData['city'] ?? '';
      reclat = userData['lat'] ?? '';
      reclong = userData['long'] ?? '';
      print('User: $recCity, Phone: $reclat, Adhar: $reclong');
    } else {
      // Document does not exist
      print('No data found for the specified UID');
    }
    // Execute the query
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .where('available', isEqualTo: true)
        .where('city', isEqualTo: recCity)
        .get();

    // Process the results
    List<DocumentSnapshot<Map<String, dynamic>>> documents = querySnapshot.docs;
    for (DocumentSnapshot<Map<String, dynamic>> document in documents) {
      // Access the user data
      Map<String, dynamic> userData = document.data()!;
      String name = userData['name'] ?? '';
      String phoneNumber = userData['number'] ?? '';
      String worcity = userData['city'] ?? '';
      String worlat=userData['lat'] ?? '';
      String worlong=userData['long'] ?? '';

      // Perform actions with the user data as needed
      print('User: $name, Phone: $phoneNumber, Adhar: $worcity');
    }
  } catch (e) {
    print('Error fetching users: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFcbc0ff),
                    title: Image.asset(
            "images/kaamtitle.png",
            width: 180,
            height: 200,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(child: Icon(AntDesign.user),),
              Tab(child: Icon(AntDesign.find),),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildProfileTab(),
            buildFindTab(),        
          ],
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget buildProfileCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildDataRow("Name :", name),
            const Divider(),
            buildDataRow("Phone Number :", phoneNumber),
            const Divider(),
            buildDataRow("Aadhar Number :", aadharNumber),
            const Divider(),
            buildDataRow("Email :", email),
          ],
        ),
      ),
    );
  }

  Widget buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(width: 8), // Adjust the width as needed
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkersList(customParameter: title)));
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
}
