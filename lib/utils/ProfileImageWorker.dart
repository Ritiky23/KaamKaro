import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureWorker with ChangeNotifier {
  final picker = ImagePicker();
  XFile? _image;
  XFile? get image => _image;
  String? imageUrl = "";
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Stream controller to notify the UI about changes in the profile image
  final _imageStreamController = StreamController<String?>.broadcast();
  Stream<String?> get imageStream => _imageStreamController.stream;

  Future<String?> pickGalleryImage(BuildContext context) async {
    try {
      final PickedFile = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);

      if (PickedFile != null) {
        _image = XFile(PickedFile.path);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _buildWaitingDialog(); // Show the waiting dialog
          },
        );

        String? imageUrl = await uploadProfileImage(_image!);

        // Close the waiting dialog
        Navigator.pop(context);

        // Notify the UI about the new image URL
        _imageStreamController.add(imageUrl);

        return imageUrl;
      }

      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String?> pickCameraImage(BuildContext context) async {
    try {
      final PickedFile = await picker.pickImage(
          source: ImageSource.camera, imageQuality: 70);

      if (PickedFile != null) {
        _image = XFile(PickedFile.path);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _buildWaitingDialog(); // Show the waiting dialog
          },
        );
        String? imageUrl = await uploadProfileImage(_image!);

        // Close the waiting dialog
        Navigator.pop(context);

        // Notify the UI about the new image URL
        _imageStreamController.add(imageUrl);

        return imageUrl;
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Widget _buildWaitingDialog() {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Uploading..."),
        ],
      ),
    );
  }

  Future<String?> uploadProfileImage(XFile pickedImage) async {
    try {
      Completer<String?> completer = Completer();
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${_auth.currentUser?.uid}.jpg');
      UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));
      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();
        print(imageUrl);
        completer.complete(imageUrl);
      });
      return completer.future;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _uploadProfileImageAndUpdate(String? imageUrl) async {
    print(imageUrl);
    if (imageUrl != null) {
      print("helooooo");
      // Update the profileImage field in Firestore
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(_auth.currentUser?.uid)
          .update({
        'profileImage': imageUrl,
      });

      // Notify the UI about the updated image URL
      _imageStreamController.add(imageUrl);

      // Update the UI
      print('Profile image uploaded and updated successfully.');
    } else {
      print('Failed to upload profile image. ${imageUrl}');
    }
  }

  void pickImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 120,
            child: Column(
              children: [
                ListTile(
                  onTap: () async {
                    String? imageUrl = await pickCameraImage(context);
                    if (imageUrl != null) {
                      _uploadProfileImageAndUpdate(imageUrl);
                      Navigator.pop(context);
                    }
                  },
                  leading: Icon(Icons.camera),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () async {
                    String? imageUrl = await pickGalleryImage(context);
                    print(imageUrl);
                    if (imageUrl != null) {
                      _uploadProfileImageAndUpdate(imageUrl);
                      Navigator.pop(context);
                    }
                  },
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dispose the stream controller when it's no longer needed
  void dispose() {
    _imageStreamController.close();
  }
}
