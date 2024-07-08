import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/Post.dart';
import 'package:socialmediaapp/models/models.dart';
import 'package:socialmediaapp/screens/LoginGithub.dart';
import 'package:socialmediaapp/screens/hello_login.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:socialmediaapp/screens/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socialmediaapp/screens/logingoogle.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:email_validator/email_validator.dart';
import 'package:socialmediaapp/screens/nav_screen.dart';
import 'package:socialmediaapp/widgets/profile_avatar.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePreviousRegister extends StatefulWidget {
  const EditProfilePreviousRegister({Key? key}) : super(key: key);

  @override
  _EditProfile createState() => _EditProfile();
}

class _EditProfile extends State<EditProfilePreviousRegister> {
  final _name = TextEditingController();
  final _birthdayController = TextEditingController();
  String ip = MyApp.ipv4;
  @override
  void dispose() {
    super.dispose();
    _name.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  late String imgUrl;
  SharedPreferences? sharedPref;
  String? path;
  String? email;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/background2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: w * 0.1,
              height: h * 0.06,
              margin: EdgeInsets.only(top: 20, bottom: 0, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[600],
              ),
              child: InkWell(
                onTap: () {
                  Saveprofile;
                },
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: w,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Setting your profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Align children in the center horizontally
                      children: [
                        if (path != null) ShowAvatar(path!) else ShowAvatar("")
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            Icons.image_outlined,
                            color: Colors.black,
                            size: 30,
                          ),
                          label: Text(
                            'Choose image',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: Offset(1, 1),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Name',
                            hintText: 'Enter your name',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                        ),
                        Divider(),
                        GestureDetector(
                          onTap: () {
                            _selectBirthday(
                                context); // Call the date picker function
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _birthdayController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                                labelText: 'Birthday',
                                hintText: 'Select your birthday',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                ),
                              ),
                              readOnly: true, // Make the field non-editable
                            ),
                          ),
                        ),
                        Divider(),
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumber = number;
                          },
                          onInputValidated: (bool value) {},
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          initialValue: _phoneNumber,
                          textFieldController: TextEditingController(),
                          inputDecoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          formatInput: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Align children in the center horizontally
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors
                                .white, // Set the foreground color (text color) of the button here
                          ),
                          onPressed: Saveprofile,
                          child: Text(
                            'next',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Format the selected date
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      // Update the text field with the selected date
      _birthdayController.text = formattedDate;
    }
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

  thongbao(String msg) {
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

  Future<Post2?> Saveprofile() async {
    if (_name.text == "" ||
        _birthdayController.text == "" ||
        _phoneNumber.phoneNumber == "" ||
        path == "") {
      thongbao("fill out all the form and choose your avatar");
    } else if (_formKey.currentState?.validate() ??
        false ||
            (_phoneNumber.phoneNumber.toString().length > 16 ||
                _phoneNumber.phoneNumber.toString().length < 12)) {
      return thongbao("Wrong phone configuration");
    } else {
      String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImagges = referenceRoot.child('images');
      Reference referenceImageToUpload =
          referenceDirImagges.child(uniqueFilename);
      try {
        await referenceImageToUpload.putFile(File(path!));
        imgUrl = await referenceImageToUpload.getDownloadURL();
      } catch (error) {}

      final url = Uri.parse("$ip/api/updateprofile");
      String tokendata = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': tokendata
      };
      sharedPref = await SharedPreferences.getInstance();

      setState(() {
        email = sharedPref?.getString("email");
      });
      print(email);
      Map<String, dynamic> request = {
        "name": _name.text,
        "avatar": imgUrl,
        "birthday": _birthdayController.text,
        "phone": _phoneNumber.phoneNumber,
        "email": email,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String Messagec = jsonResponse['message'];
        thongbao(Messagec);
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavScreen()),
        );
      } else if (response.statusCode == 404) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        deleteImageFromStorage(imgUrl);
        return thongbao(errorMessage);
      } else {
        print(response.statusCode);
        throw Exception("failed");
      }
    }
  }

  ShowAvatar(String imagePath) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 100.0,
          backgroundColor: Palette.facebookBlue,
          child: CircleAvatar(
            radius: 100.0,
            backgroundColor: Colors.grey[200],
            backgroundImage: FileImage(File(imagePath)),
          ),
        ),
      ],
    );
  }

  void deleteImageFromStorage(String imageUrl) async {
    // Lấy đối tượng Reference của ảnh cần xóa
    Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);

    try {
      // Thực hiện xóa ảnh
      await imageRef.delete();
      print('Đã xóa ảnh thành công');
    } catch (error) {
      print('Lỗi khi xóa ảnh: $error');
    }
  }
}
