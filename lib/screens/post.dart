import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:socialmediaapp/data/GetCurrentUser.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/models/user_model.dart';
import 'package:socialmediaapp/screens/nav_screen.dart';
import 'package:socialmediaapp/widgets/profile_avatar.dart';
import 'package:http/http.dart' as http;

class Postcontent extends StatefulWidget {
  final User currentUser;
  const Postcontent({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  _PostcontentState createState() => _PostcontentState();
}

class _PostcontentState extends State<Postcontent> {
  final _content = TextEditingController();
  String? path;
  String? imgUrl;
  String? email;
  String ip = MyApp.ipv4;
  SharedPreferences? sharedPref;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create new post'),
        actions: [
          TextButton(
            onPressed: () {
              SendPost();
            },
            child: Text(
              'POST',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(imageUrl: widget.currentUser.imageUrl),
              const SizedBox(width: 8.0),
              Text(
                widget.currentUser.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 200, // Set a default height
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _content,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(
                8.0), // Thêm padding 8.0 pixels cho tất cả các cạnh
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (path != null) ShowAvatar(path!),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    ImagePicker imagePicker = ImagePicker();
                    XFile? file = await imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (file == null) return;
                    setState(() {
                      path = file.path;
                    });
                  },
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.green,
                  ),
                  label: Text('Photo'),
                ),
                TextButton.icon(
                  onPressed: () {
                    print("add tag friend to content");
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.blue,
                  ),
                  label: Text('Tag friends'),
                ),
                TextButton.icon(
                  onPressed: () {
                    print("add location to content");
                  },
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.pink,
                  ),
                  label: Text('Add location'),
                ),
                TextButton.icon(
                  onPressed: () {
                    print("add emoji to content");
                  },
                  icon: const Icon(
                    Icons.emoji_emotions,
                    color: Colors.yellow,
                  ),
                  label: Text('Add emoji/activity'),
                ),
                TextButton.icon(
                  onPressed: () {
                    print("create event");
                  },
                  icon: const Icon(
                    Icons.calendar_month,
                    color: Colors.pink,
                  ),
                  label: Text('Create event'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: TextButton(
                      onPressed: () {
                        SendPost();
                      },
                      child: Text(
                        'POST',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getCurrentUser() async {
    final getCurrentUser = GetCurrentUser();
    final user = await getCurrentUser.getUser();
    print('Name: ${user.name}');
    print('Image URL: ${user.imageUrl}');
  }

  Widget ShowAvatar(String imagePath) {
    return Stack(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Palette.facebookBlue, // Màu nền của container
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(5), // Bo tròn các góc của hình ảnh
            child: Image.file(
              File(imagePath),
              width: 60, // Đặt chiều rộng của hình ảnh
              height: 60, // Đặt chiều cao của hình ảnh
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.close),
            color: Colors.white,
            onPressed: () {
              setState(() {
                path = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Future<String> fetchCsrfToken() async {
    final response = await http.get(Uri.parse('$ip/csrf-token'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['csrf_token'];
    } else {
      throw Exception('Failed to fetch CSRF token');
    }
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

  Future<void> SendPost() async {
    if (_content.text.isEmpty) {
      thongbao("Thêm nội dung");
      return;
    }

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFilename);

    try {
      if (path != null) {
        await referenceImageToUpload.putFile(File(path!));
        imgUrl = await referenceImageToUpload.getDownloadURL();
      }

      final url = Uri.parse("$ip/api/postcontent");
      String csrfToken = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken
      };

      sharedPref = await SharedPreferences.getInstance();
      email = sharedPref?.getString("email");

      Map<String, dynamic> request = {
        "media": imgUrl,
        "content": _content.text,
        "email": email,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String message = jsonResponse['message'];
        thongbao(message);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavScreen()),
        );
      } else if (response.statusCode == 404) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        deleteImageFromStorage(imgUrl!);
        thongbao(errorMessage);
      } else {
        throw Exception("Failed to post content");
      }
    } catch (error) {
      thongbao("Error: $error");
    }
  }

  void deleteImageFromStorage(String imageUrl) async {
    Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    try {
      await imageRef.delete();
      print('Image deleted successfully');
    } catch (error) {
      print('Error deleting image: $error');
    }
  }
}
