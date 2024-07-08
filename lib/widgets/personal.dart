import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/models.dart';
import 'package:http/http.dart' as http;

class Personal extends StatefulWidget {
  final User currentUser;

  const Personal({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  _PersonalState createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  String? imagePath;
  late String imgUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 6.0),
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.network(
                'https://i.pinimg.com/736x/ec/34/67/ec3467fc6297343e455b9c6ce3f16070.jpg',
                width: 400,
                height: 300,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: -50.0,
                left: 16.0,
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Palette.facebookBlue,
                  child: CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        CachedNetworkImageProvider(widget.currentUser.imageUrl),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.currentUser.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 30.0),
              TextButton(
                child: Text("Edit Profile"),
                onPressed: () {
                  showEditProfileModal(context, widget.currentUser.name,
                      widget.currentUser.imageUrl, widget.currentUser.id);
                },
              ),
            ],
          ),
          Divider(height: 10.0, thickness: 0.5),
        ],
      ),
    );
  }

  void showEditProfileModal(
      BuildContext context, String name, String avatarUrl, String id) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        ImagePicker imagePicker = ImagePicker();
                        XFile? file = await imagePicker.pickImage(
                            source: ImageSource.gallery);
                        if (file == null) return;
                        setState(() {
                          imagePath = file.path;
                        });
                      },
                      child: CircleAvatar(
                        radius: 45.0,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: imagePath != null
                            ? FileImage(File(imagePath!))
                            : CachedNetworkImageProvider(avatarUrl),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      name = value.toString();
                    },
                  ),
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // Button color
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        updateProfile(name, imagePath, id, context, avatarUrl);
                      },
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void thongbao(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<String> fetchCsrfToken() async {
    String ip = MyApp.ipv4;
    final response = await http.get(Uri.parse('$ip/csrf-token'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['csrf_token'];
    } else {
      throw Exception('Failed to fetch CSRF token');
    }
  }

  Future<void> updateProfile(String name, String? imagePath, String id,
      BuildContext context, String avatarUrl) async {
    if (imagePath == null) {
      imgUrl = avatarUrl;
    } else {
      String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImagges = referenceRoot.child('images');
      Reference referenceImageToUpload =
          referenceDirImagges.child(uniqueFilename);
      try {
        await referenceImageToUpload.putFile(File(imagePath!));
        imgUrl = await referenceImageToUpload.getDownloadURL();
      } catch (error) {}
    }
    String ip = MyApp.ipv4;
    final url = Uri.parse('$ip/api/updateprofile2'); // Adjust the endpoint
    String tokenData = await fetchCsrfToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokenData,
    };

    Map<String, dynamic> request = {"id": id, "name": name, "avatar": imgUrl};

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      // Handle success scenario if needed
      Fluttertoast.showToast(
        msg: 'Profile updated!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(
          context); // Close modal bottom sheet after successful update
    } else {
      // Handle error scenario
      Fluttertoast.showToast(
        msg: 'Failed to update profile!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
