import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:kaamkaro/models/Worker.dart';
import 'package:kaamkaro/screens/FindingScreen.dart';

class UserProfileScreen extends StatefulWidget {
  final String wuid;
  UserProfileScreen({required this.wuid});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CircleAvatar dp = CircleAvatar(
    child: Icon(AntDesign.user),
    radius: 50,
  );
  
  String name = "";
  String city = "";
  String phoneNumber = "";
  String email = "";
  double rating = 0.0;
  int totalWork = 0;
  String profession="";
  bool sent = false;
  bool accepted=false;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    checkIfUserRequested();
  }


  Future<void> sendRequestAndUpdateRecruiterData(String workerUid) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      String recuid = user!.uid;
      // Update the worker's document with the request
      print(recuid);
      print(workerUid);
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerUid)
          .update({
        'requests.$recuid': false,
      });
      print( FirebaseFirestore.instance
          .collection('workers')
          .doc(workerUid)
          .update({
        'requests.$recuid': false,
      }));
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
    DocumentReference<Map<String, dynamic>> workerRef =
        FirebaseFirestore.instance.collection('workers').doc(workerUid);

    // Listen to changes in the 'requests' field of the worker document
    workerRef.snapshots().listen((workerSnapshot) {
      if (workerSnapshot.exists) {
        Map<String, dynamic> workerData = workerSnapshot.data()!;
        
        if (workerData['requests'].containsKey(user?.uid)) {
          bool requestStatus = workerData['requests'][user?.uid];
          accepted = requestStatus;
        } else {
          accepted = false;
        }
      } else {
        accepted = false;
      }
    });

    // Initial check
    DocumentSnapshot<Map<String, dynamic>> initialSnapshot = await workerRef.get();
    if (initialSnapshot.exists) {
      Map<String, dynamic> initialData = initialSnapshot.data()!;
      if (initialData['requests'].containsKey(user?.uid)) {
        bool requestStatus = initialData['requests'][user?.uid];
        accepted = requestStatus;
        return initialData['requests'].containsKey(user?.uid);
      }
    }

    accepted = false;
    return false; // Worker document doesn't exist or requests is not iterable
  } catch (e) {
    print('Error checking if current user is in worker requests: $e');
    accepted = false;
    return false;
  }
}

  Future<void> checkIfUserRequested() async {
    bool isRecruiterInRequests = await isCurrentUserInWorkerRequests(widget.wuid);
    setState(() {
      sent = isRecruiterInRequests;
      print("here ${isRecruiterInRequests}");
    });
  }


Future<void> fetchProfileData() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('workers').doc(widget.wuid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        setState(() {
          name = data['name'] ?? "__";
          phoneNumber = data['number'] ?? "__";
          email = data['email'] ?? "__";
          city = data['city'] ?? "__";
          rating = data['rating'] ?? 0.0;
          totalWork = data['totalWork'] ?? 0;
          profession = data['profession'] ?? "__";
        });
      }

      // Set up a stream listener to get real-time updates
      FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.wuid)
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Map<String, dynamic> data = event.data()!;
          setState(() {
            accepted = data['requests'][user?.uid] ?? false;
          });
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Worker Profile'),
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
                    totalWork.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
               Column(
                children: [
                  Text(
                    'Profession',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    profession,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 40,),
         AnimatedSwitcher(
  duration: const Duration(milliseconds: 500),
  child: accepted
      ? SelectableText(
          phoneNumber,
          style: TextStyle(fontSize: 18),
        )
      : Text(
          '   ',
          style: TextStyle(fontSize: 18),
        ),
),
          SizedBox(height: 40,),
           Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
AnimatedSwitcher(
  duration: const Duration(milliseconds: 500),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: accepted ? Colors.green : Color(0xFF4b5ebc),
    ),
    onPressed: () async {
      // Check if the current recruiter's UID is in the worker's requests list
      if (sent || accepted) {
        setState(() {
          sent = false;
        });
      } else {
        setState(() {
          sent = true;
          sendRequestAndUpdateRecruiterData(wuid);
        });
      }
    },
    key: ValueKey<bool>(accepted), // Ensure a new key when 'accepted' changes
    child: Text(
      accepted ? 'Accepted' : (sent ? 'Requested' : 'Request Work'),
      style: TextStyle(color: Colors.white),
    ),
  ),
)

,
  ElevatedButton(style: ElevatedButton.styleFrom(primary: Color(0xFF4b5ebc)),
              onPressed: () {
                 _showReviewDialog();
              },
              child: Text('Work Done',style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(
        Icons.star,
        // size: 30.0,
        color: _stars >= starCount ? Colors.orange : Colors.grey,
      ),
      onTap: () {
        setState(() {
          _stars = starCount;
        });
      },
    );
  }
Future<void> _showReviewDialog() async {
  int? userRating;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
      title: Center(child: Text('Rate the Worker'),),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildStar(1),
          _buildStar(2),
          _buildStar(3),
          _buildStar(4),
          _buildStar(5),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('cancel'),
          onPressed: Navigator.of(context).pop,
        ),
        ElevatedButton(
          child: Text('Submit'),
          onPressed: () {
            Navigator.of(context).pop(_stars);
          },
        )
      ],
    );
    },
  );
}

}