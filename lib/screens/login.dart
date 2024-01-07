import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaamkaro/screens/RecruiterHomeScreen.dart';
import 'package:kaamkaro/screens/WorkerHomeScreen.dart';
import 'package:kaamkaro/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      String userrole = '';
      String uid = userCredential.user!.uid;

      DocumentSnapshot recruiterdoc =
          await FirebaseFirestore.instance.collection('recruiters').doc(uid).get();
      if (recruiterdoc.exists) {
        userrole = 'recruiter';
        print('recrri');
      } else {
        DocumentSnapshot workerdoc =
            await FirebaseFirestore.instance.collection('workers').doc(uid).get();
        if (workerdoc.exists) {
          userrole = 'worker';
          print(userrole);
        }
      }
      if (userrole == 'worker') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkerHomeScreen()),
        );
      } else if (userrole == 'recruiter') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecruiterHomeScreen()),
        );
      }
      print('Login successful: ${userCredential.user!.email}');
    } else {
      print("Login Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      validator: (newValue) {
        if (newValue!.isEmpty) {
          return ("Email is required");
        }
      },
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) {
        emailController.text = newValue!;
      },
      textInputAction: TextInputAction.next,
      style: TextStyle(color: Color(0xFF858485)),
 decoration: InputDecoration(
    prefixIcon: Icon(Icons.mail_outline, color: Color(0xFF858485)),
    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
    hintText: "Email",
    hintStyle: TextStyle(color: Color(0xFF858485)),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color.fromARGB(255, 254, 254, 254)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color.fromARGB(255, 81, 78, 77)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF4b5ebc)),
    ),
  ),
    );

    final passField = TextFormField(
      autofocus: false,
      controller: passwordController,
      validator: (newValue) {
        RegExp regex = new RegExp(r'^.{6}$');
        if (newValue!.isEmpty) {
          return ("Password is required");
        }
      },
      onSaved: (newValue) {
        emailController.text = newValue!;
      },
      textInputAction: TextInputAction.next,
      style: TextStyle(color: Color(0xFF858485)),
      obscureText: true,
       decoration: InputDecoration(
    prefixIcon: Icon(Icons.password_outlined, color: Color(0xFF858485)),
    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
    hintText: "Password",
    hintStyle: TextStyle(color: Color(0xFF858485)),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color.fromARGB(255, 254, 254, 254)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color.fromARGB(255, 81, 78, 77)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF4b5ebc)),
    ),
  ),
    );

    final loginButton = ElevatedButton(
      onPressed: () async {
        await _login();
      },
      style: ElevatedButton.styleFrom(primary: Color(0xFF4b5ebc)),
      child: Text(
        "Login",
        style: TextStyle(color: Colors.white),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFcbc0ff),
              Color(0xFFcbc0ff),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              color: Color.fromARGB(0, 255, 255, 255),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 250,
                      width: 300,
                      child: Image.asset(
                        "images/kaamkaro23.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                      child: emailField,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                      child: passField,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    loginButton,
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("New User? ",style: TextStyle(color: Colors.white),),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
