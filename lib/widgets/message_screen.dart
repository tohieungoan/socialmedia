import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/getcontentmessage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:socialmediaapp/screens/videocall.dart';

class MessageScreen extends StatefulWidget {
  final String friendName;
  final String friendAvatar;
  final String idofme;
  final String idfriend;
  final String idwechat;
  final String token;
  final String chatkey;
  final String myname;
  final List<Getcontentmessage> messages;

  const MessageScreen({
    Key? key,
    required this.friendName,
    required this.myname,
    required this.chatkey,
    required this.token,
    required this.friendAvatar,
    required this.idofme,
    required this.idfriend,
    required this.idwechat,
    required this.messages,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _messageController = TextEditingController();
  File? _selectedImage;
  late ScrollController _scrollController;

  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('/chatlist');

  List<Getcontentmessage> _messages = [];
  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
    _scrollController = ScrollController();
    _messagesRef.child(widget.chatkey).onChildAdded.listen(_onMessageAdded);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _onMessageAdded(DatabaseEvent event) async {
    getmessage();
  }

  Future<void> getmessage() async {
    String ip = MyApp.ipv4;
    final url = Uri.parse('$ip/api/getlistmessage');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': widget.token,
    };

    Map<String, dynamic> request = {
      "idfriend": widget.idfriend,
      "idofme": widget.idofme,
      "idwechat": widget.idwechat,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['messages']; // Corrected key access
      List<Getcontentmessage> contentlist = [];
      for (var contentData in message) {
        final idofme = contentData['idofme'];
        final timecreate = contentData['timecreate'];
        final linkmedia = contentData['linkmedia'];
        final content = contentData['content'];
        contentlist.add(Getcontentmessage(
          idofme: idofme,
          timecreate: timecreate,
          linkmedia: linkmedia,
          content: content,
        ));
      }
      setState(() {
        _messages = contentlist;
      });
    } else if (response.statusCode == 202) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      String name = data['name'];
      String avatar = data['avatar'];
      List<Getcontentmessage> contentlist = [];

      // Navigate to the MessageScreen and pass necessary data
    } else {
      throw Exception("Failed to perform action");
    }
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.friendAvatar),
            ),
            SizedBox(width: 10),
            Text(widget.friendName),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              print("call");
            },
          ),
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {
              navigateToCall(
                  context, widget.chatkey, widget.myname, widget.idofme);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isMyMessage = message.idofme == widget.idofme;

                return Align(
                  alignment: isMyMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMyMessage ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.content != "null" ||
                            message.content != "image")
                          Text(
                            message.content!,
                            style: TextStyle(color: Colors.white),
                          ),
                        if (message.linkmedia != "null")
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenImage(
                                    imageUrl: message.linkmedia!,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: message.linkmedia!,
                              child: Image.network(
                                message.linkmedia!,
                                height: 100,
                                width: 100,
                              ),
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          message.timecreate!,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildChatInputField(),
        ],
      ),
    );
  }

  Widget _buildChatInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _selectedImage = File(pickedFile.path);
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.insert_emoticon),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) {
                _sendMessage(widget.idwechat, widget.idfriend, widget.idofme);
              },
              maxLines: null, // Cho phép nhập nhiều dòng
              keyboardType: TextInputType
                  .multiline, // Thiết lập kiểu bàn phím là multiline
              textInputAction: TextInputAction
                  .newline, // Thiết lập hành động khi nhấn enter là xuống dòng
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(widget.idwechat, widget.idfriend, widget.idofme);
            },
          ),
        ],
      ),
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

  void navigateToCall(
      BuildContext context, String? chatkey, String? myname, String? idofme) {
    if (chatkey != null && myname != null && idofme != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Videocall(chatkey: chatkey, myname: myname, idofme: idofme),
        ),
      );
    } else {
      // Handle the null case appropriately, maybe show a message to the user
      print("Error: One of the required parameters is null.");
    }
  }

  Future<void> _sendMessage(
      String idwechat, String idfriend, String idofme) async {
    if (_messageController.text.trim().isEmpty && _selectedImage == null) {
      thongbao("No message to send");
      return;
    }

    String ip = MyApp.ipv4;
    final url = Uri.parse('$ip/api/sendmessage');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': widget.token,
    };

    String imgurl = "null";
    if (_selectedImage != null) {
      String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFilename);
      try {
        await referenceImageToUpload.putFile(_selectedImage!);
        imgurl = await referenceImageToUpload.getDownloadURL();
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }

    Map<String, dynamic> request = {
      "idfriend": idfriend,
      "idofme": idofme,
      "idwechat": idwechat,
      "message": _messageController.text,
      "media": imgurl,
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
    } else if (response.statusCode == 404) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String message = jsonResponse['message'];
      thongbao(message);
    } else {
      throw Exception("Failed to perform action");
    }

    _messageController.clear();
    setState(() {
      _selectedImage = null;
    });
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            child: CachedNetworkImage(imageUrl: imageUrl),
            boundaryMargin: EdgeInsets.all(20.0),
            minScale: 0.1,
            maxScale: 4.0,
          ),
        ),
      ),
    );
  }
}
