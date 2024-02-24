import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaamkaro/models/Recruiter.dart';
import 'package:kaamkaro/models/Worker.dart';
import 'package:kaamkaro/screens/RecruiterHomeScreen.dart';
import 'package:kaamkaro/screens/WorkerHomeScreen.dart';
import 'package:kaamkaro/screens/login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kaamkaro/utils/location.dart';

//import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController NameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController AadharController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
    String proff = 'Labour';
    bool dropdownworker=true;
    String role='worker';

    String cityName='';
    double lat=0;
    double long=0;
  
  // List of items in our dropdown menu 
  var items = [     
    'Labour', 
    'Carpenter', 
    'Plumber', 
    'Cleaner',  
  ];
  int? selectedValue=1;
   InputDecoration buildInputDecoration(IconData prefixIcon, String hintText) {
    return InputDecoration(
    prefixIcon: Icon(prefixIcon, color: Color(0xFF858485)),
    contentPadding: EdgeInsets.fromLTRB(-30, 15, 20,-30),
    hintText: hintText,
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
  );
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
  @override
  Widget build(BuildContext context) {
      final NameField=TextFormField(
      controller: NameController,
      validator: (newValue){
        if(newValue!.isEmpty){
          return("Name is required");
        }
      },
      autofocus: false,
      keyboardType: TextInputType.name,
      onSaved: (newValue) {
        NameController.text=newValue!;
      },
      textInputAction: TextInputAction.next,
      
      decoration: buildInputDecoration(AntDesign.edit, "Name")
      );

      final NumberField=TextFormField(
      controller: phoneNumberController,
      validator: (newValue){
        if(newValue!.isEmpty){
          return("Phone Number is required");
        }
      },
      autofocus: false,
      keyboardType: TextInputType.number,
      onSaved: (newValue) {
        phoneNumberController.text=newValue!;
      },
      textInputAction: TextInputAction.next,
      decoration: buildInputDecoration(Icons.call_end_outlined, "Phone Number")
      );
      final AadharField=TextFormField(
      controller: AadharController,
      validator: (newValue){
        if(newValue!.isEmpty){
          return("Aadhaar Number is required");
        }
      },
      autofocus: false,
      keyboardType: TextInputType.numberWithOptions(),
      onSaved: (newValue) {
        AadharController.text=newValue!;
      },
      textInputAction: TextInputAction.next,
      decoration: buildInputDecoration(Icons.credit_card, "Aadhaar Number"),);

    final emailField=TextFormField(
      controller: emailController,
        validator: (newValue){
        if(newValue!.isEmpty){
          return("Email is required");
        }
      },
      autofocus: false,
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) {
        emailController.text=newValue!;
      },

      textInputAction: TextInputAction.next,
      decoration: buildInputDecoration(Icons.mail_outline, "Email"),
      );

      final passField=TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      validator: (newValue){
        if(newValue!.isEmpty){
          return("Password is required");
        }
        if(newValue.length<6){
          return ("Enter Valid Password(Min. 6 Character)");
        }
        return null;
      },
      onSaved: (newValue) {
        passwordController.text=newValue!;
      },
      textInputAction: TextInputAction.next,
            decoration: InputDecoration(
    prefixIcon: Icon(Icons.password_outlined, color: Color(0xFF858485)),
    contentPadding:EdgeInsets.fromLTRB(0, 15, 20, 0),
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
      final cpassField=TextFormField(
      autofocus: false,
      controller: confirmpasswordController,
      obscureText: true,
      validator: (newValue){
          if(newValue!.isEmpty){
          return "Retype Password is required";
        }
        if(confirmpasswordController.text!=passwordController.text){
          return "Password Don't Match";
        }
        return null;
      } ,
      onSaved: (newValue) {
        confirmpasswordController.text=newValue!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
    prefixIcon: Icon(Icons.password_outlined, color: Color(0xFF858485)),
    contentPadding: EdgeInsets.fromLTRB(0, 15, 20, 0),
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
      final signupButton=ElevatedButton(
          onPressed: (){
            String e=emailController.text;
            String p=passwordController.text;
            showLoaderDialog(context);
            signUp(e, p);
            
          },      style: ElevatedButton.styleFrom(primary: Color(0xFF4b5ebc)),
      child: Text(
        "Sign Up",
        style: TextStyle(color: Colors.white),
      ),
          );

  
    return Scaffold(
      backgroundColor: Color(0xFFcbc0ff),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Color(0xFFcbc0ff),
            child: Form(key: _formKey,
            child: Column(children: <Widget>[
              SizedBox(
                height: 130,
                width: 300,
                child: Image.asset("images/kaamkaro23.png",
                ),
              ),
             Text(
            'KaamKaro',
            style: GoogleFonts.bebasNeue(
              textStyle: TextStyle(
                fontSize: 40.0, // Adjust the size as needed
                color: Colors.white,
                letterSpacing: 5.0,
                
              ),),),
              Row(children: <Widget>[
                SizedBox(width: 80,),
                Radio<int>(
                value: 1,
                groupValue: selectedValue,
                onChanged: (int? value) {
                  role='worker';
                  onRadioValueChanged(value);
                 // role='worker';
                },
              ),
              Text('Worker'),
              Radio<int>(
                value: 2,
                groupValue: selectedValue,
                onChanged: (int? value) {
                  role='recruiter';
                  onRadioValueChanged(value);
                  //role='recruiter';
                },
              ),
              Text('Recruiter'),],),
            
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40.0),
              child: NameField,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40.0),
              child: NumberField,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40.0),
              child: AadharField,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40.0),
              child: emailField,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40.0),
              child: passField,
            ),
              SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40.0),
              child: cpassField,
            ),
            SizedBox(height: 10,),
            if (dropdownworker)
              Container(
                padding: EdgeInsets.only(left: 10),
  decoration: BoxDecoration(
    color: Color(0xFF4b5ebc),
    borderRadius: BorderRadius.circular(50),
  ),
                child: DropdownButton(
                  value: proff,
                    dropdownColor: Color(0xFFcbc0ff),
                  items: items.map((String item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Text(item,style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      proff = newValue!;
                      print(newValue!);
                    });
                  },
                    icon: Padding(
                      padding: const EdgeInsets.only(right:10.0),
                      child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                                        ),
                    ),
                   underline: SizedBox(),
                   
                
                ),
              ),  

            signupButton,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Already Have Account? "),
                GestureDetector(
                  onTap: () { Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>LoginScreen()));
                  },
                  child: Text("Login",style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),),
                )
              ],
            )

            ]),
            ),
          ),
        ),
      ),
    );
  }


  void onRadioValueChanged(int? value) {
        setState(() {
      // Update the state to reflect the selected value
      selectedValue = value;
      if(selectedValue==1){
        dropdownworker=true;
      }
      else{
        dropdownworker=false;
      }
      // Handle the change in selected radio button
      // You can perform actions based on the selected value
      print('Selected value: $value');
    });
  }

void signUp(String email, String password) async {
  getLoc location=getLoc();
  Map<String, dynamic> locationData = await location.getCurrentLocation();
  cityName=locationData['city'];
  lat=locationData['lat'];
  long=locationData['long'];

  if (_formKey.currentState!.validate()) {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      postDetailsToFirestore(userCredential.user!);
      if(role=='worker'){
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkerHomeScreen(),),);
      }else if(role=='recruiter'){
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context)=>RecruiterHomeScreen(),),);
      }
    } catch (e) {
      print('Error during registration: $e');
      String errorMessage = 'Error during registration. Please try again.';
      if (e is FirebaseAuthException) {
        errorMessage = e.message!;
      }
      Fluttertoast.showToast(msg: errorMessage);
    }
  }
}
void postDetailsToFirestore(User? user) async {
  FirebaseFirestore firebaseFirestore=FirebaseFirestore.instance;
  if (user!= null) {
    String uid = user.uid;
    RecruiterModel recruiterModel = RecruiterModel();
      recruiterModel.uid= user.uid;
      recruiterModel.email=user!.email;
      recruiterModel.name= NameController.text;
      recruiterModel.number= phoneNumberController.text;
      recruiterModel.adhaar= AadharController.text;
      recruiterModel.role= role;
      recruiterModel.city= cityName; // Add the location as needed
      recruiterModel.lat=lat;
      recruiterModel.long=long;
   // print(phoneNumberController.toString());
    WorkerModel workerModel = WorkerModel();
      workerModel.uid= user.uid;
      workerModel.email=user!.email;
      workerModel.name= NameController.text;
      workerModel.number= phoneNumberController.text;
      workerModel.adhaar= AadharController.text;
      workerModel.role= role;
      workerModel.profession=proff;
      workerModel.city= cityName; // Add the location as needed
      workerModel.lat=lat;
      workerModel.long=long;
    // Print values from form controllers
    if (workerModel.isWorker()) {
      print(user.uid);
      await firebaseFirestore.collection('workers').doc(user.uid).set(workerModel.toMap());
    } else if (recruiterModel.isRecruiter()) {
      await firebaseFirestore.collection('recruiters').doc(user.uid).set(recruiterModel.toMap());
    }
  }
}
  }
