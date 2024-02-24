import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';

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
    backgroundImage: AssetImage("images/work1.jpg"),
    radius: 50,
  );

  String name = "";
  String city = "";
  String phoneNumber = "";
  String email = "";
  double rating = 0.0;
  
  String profession = "";
  bool sent = false;
  bool accepted = false;
  String profileImg='';
  double _stars = 0.0;
  int TotalWork=0;

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
        'requested.$workerUid': false,
      });

      // Display a success message or handle UI updates as needed
      print('Request sent successfully');
    } catch (e) {
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
      DocumentSnapshot<Map<String, dynamic>> initialSnapshot =
          await workerRef.get();
      if (initialSnapshot.exists) {
        Map<String, dynamic> initialData = initialSnapshot.data()!;
        if (initialData['requests'].containsKey(user?.uid)) {
          bool requestStatus = initialData['requests'][user?.uid];
          accepted = requestStatus;
          return initialData['requests'].containsKey(user?.uid);
        }
      }

      accepted = false;
      return false;
    } catch (e) {
      print('Error checking if the current user is in worker requests: $e');
      accepted = false;
      return false;
    }
  }

  Future<void> checkIfUserRequested() async {
    bool isRecruiterInRequests =
        await isCurrentUserInWorkerRequests(widget.wuid);
    setState(() {
      sent = isRecruiterInRequests;
    });
  }

  Future<void> fetchProfileData() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User? user = _auth.currentUser;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('workers')
          .doc(widget.wuid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        setState(() {
          name = data['name'] ?? "__";
          phoneNumber = data['number'] ?? "__";
          email = data['email'] ?? "__";
          city = data['city'] ?? "__";
          rating = data['averageRating'] ?? 0.0;
          TotalWork = data['TotalWork'] ?? 0;
          profession = data['profession'] ?? "__";
          profileImg=data['profileImage']??"";
        });
      }

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
            onTap: () {},
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: (profileImg!= null && profileImg.isNotEmpty)
                          ? Image.network(
                              profileImg,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFFcbc0ff),
                              child: const Icon(AntDesign.user, size: 50, color: Colors.white),
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
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 10,),
                      Text(
                        rating.toStringAsFixed(1),
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
                    TotalWork.toString(),
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
          SizedBox(
            height: 40,
          ),
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
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary:
                        accepted ? Colors.green : Color(0xFF4b5ebc),
                  ),
                  onPressed: () async {
                    if ( sent || accepted ) {
                      setState(() {
                        sent = false;
                      });
                    } else {
                      setState(() {
                        sent = true;
                        sendRequestAndUpdateRecruiterData(widget.wuid);
                      });
                    }
                  },
                  key: ValueKey<bool>(accepted),
                  child: Text(
                    accepted
                        ? 'Accepted'
                        : (sent ? 'Requested' : 'Request Work'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF4b5ebc),
                ),
                onPressed: () {
                  _showReviewDialog();
                },
                child: Text('Work Done', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
Future<void> _showReviewDialog() async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text('Rate the Work')),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RatingBar.builder(initialRating: 3,
   minRating: 1,
   direction: Axis.horizontal,
   allowHalfRating: true,
   itemCount: 5,
   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
   itemBuilder: (context, _) => Icon(
     Icons.star,
     color: Colors.amber,
   ),
   onRatingUpdate: (rating) {
     _stars=rating;
     print(rating);
   },
),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).pop,
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              // Call submitRating function with selected rating value
              submitRating(widget.wuid, _stars.toDouble());
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
// Function to submit a rating for a worker
Future<void> submitRating(String workerId, double ratingValue) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('workers').doc(workerId).get();

    List<dynamic> ratings = snapshot.data()?['ratings'] ?? [];

    print('Ratings before adding: $ratings');

    // Add the new rating to the existing array
    ratings.add(ratingValue);

    print('Ratings after adding: $ratings');

    // Update WorkerModel object in Firestore with the updated ratings array
    await FirebaseFirestore.instance.collection('workers').doc(workerId).update({
      'ratings': ratings,
    });
    // Calculate the average rating for the worker
    double averageRating = await calculateAverageRating(workerId);

    // Update the Firestore document with the updated average rating
    await FirebaseFirestore.instance.collection('workers').doc(workerId).update({
      'averageRating': averageRating,
    });
    await FirebaseFirestore.instance.collection("workers").doc(workerId).update({
      'TotalWork': TotalWork
    });
    Navigator.of(context).pop();
  } catch (error) {
    print('Error submitting rating: $error');
  }
}

void showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
       CircularProgressIndicator(
        color: Color(0xFFcbc0ff) ,
       ),
        Container(
          margin: EdgeInsets.only(left: 7),
          child: Text("Signing",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ],
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

// Function to calculate the average rating for a worker
Future<double> calculateAverageRating(String workerId) async {
  try {
    // Retrieve the WorkerModel object from Firestore
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('workers').doc(workerId).get();

    // Retrieve the ratings list from the WorkerModel object
    List<dynamic>? ratings = snapshot.data()?['ratings'];

    // If ratings list is empty or null, return 0
    if (ratings == null || ratings.isEmpty) {
      return 0.0;
    }

    // Calculate the average rating
    double totalRating = ratings.map((rating) => rating.toDouble()).reduce((a, b) => a + b);
    TotalWork=ratings.length;
    return totalRating / ratings.length;
  } catch (error) {
    print('Error calculating average rating: $error');
    return 0.0;
  }
}
}