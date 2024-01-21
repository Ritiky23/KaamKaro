import 'package:flutter/material.dart';

class WorkerRecProfileWithoutAadhaar extends StatelessWidget {
  final String name;
  final String city;
  final String phoneNumber;
  final String email;

  WorkerRecProfileWithoutAadhaar({
    required this.name,
    required this.city,
    required this.phoneNumber,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFcac1ff),
        title: Text('Profile Details'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Assuming dp is an Image or Widget representing the profile picture
            // Replace it with your actual DP widget or image
            CircleAvatar(
              radius: 50,
              // replace 'dp' with your actual profile picture widget or image
              backgroundImage: AssetImage('images/dp_mine.jpg'),
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
            const SizedBox(height: 20),
            // Additional profile details (phone number and email)
            buildProfileCard(),
          ],
        ),
      ),
    );
  }

  Widget buildProfileCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Color.fromARGB(255, 240, 240, 240),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildDataRow(Icons.phone, "Phone Number :", phoneNumber),
            const Divider(),
            buildDataRow(Icons.email, "Email :", email),
          ],
        ),
      ),
    );
  }

  Widget buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(width: 8),
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
}
