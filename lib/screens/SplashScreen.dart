import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaamkaro/screens/RecruiterHomeScreen.dart';
import 'package:kaamkaro/screens/WorkerHomeScreen.dart';
import 'package:kaamkaro/screens/login.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            );
          } else {
            if (snapshot.hasData) {
              // User is authenticated, determine user role
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('recruiters')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> recruiterSnapshot) {
                  if (recruiterSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    );
                  } else {
                    if (recruiterSnapshot.hasData && recruiterSnapshot.data!.exists) {
                      // User exists in recruiters collection, navigate to recruiter home screen
                      return RecruiterHomeScreen();
                    } else {
                      // User doesn't exist in recruiters collection, check workers collection
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('workers')
                            .doc(snapshot.data!.uid)
                            .get(),
                        builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> workerSnapshot) {
                          if (workerSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            );
                          } else {
                            if (workerSnapshot.hasData && workerSnapshot.data!.exists) {
                              // User exists in workers collection, navigate to worker home screen
                              return WorkerHomeScreen();
                            } else {
                              // User doesn't exist in workers collection either, show error
                              return Text('User not found'); // Handle error
                            }
                          }
                        },
                      );
                    }
                  }
                },
              );
            } else {
              return LoginScreen(); // Navigate to login screen if user is not authenticated
            }
          }
        },
      ),
    );
  }
}
