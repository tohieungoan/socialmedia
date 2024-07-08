import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:socialmediaapp/config/palette.dart';
import 'package:socialmediaapp/main.dart';
import 'package:socialmediaapp/models/models.dart';
import 'package:socialmediaapp/widgets/profile_avatar.dart';
import 'package:http/http.dart' as http;

class PostContainer extends StatelessWidget {
  final Post post;
  final String email;

  const PostContainer({Key? key, required this.post, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PostHeader(post: post),
                const SizedBox(height: 4.0),
                Text(post.content),
                post.linkmedia != "null"
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 6.0),
              ],
            ),
          ),
          post.linkmedia != "null"
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImage(
                            imageUrl: post.linkmedia,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: post.linkmedia,
                      child: CachedNetworkImage(imageUrl: post.linkmedia),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _PostStats(post: post, email: email),
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final Post post;

  const _PostHeader({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(imageUrl: post.avatar),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.nameuser,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text(
                    '${post.timecreate} . ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  ),
                  Icon(Icons.public, color: Colors.grey[600], size: 12.0),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => print("more"),
        ),
      ],
    );
  }
}

class _PostStats extends StatefulWidget {
  final Post post;
  final String email;

  const _PostStats({Key? key, required this.post, required this.email})
      : super(key: key);

  @override
  __PostStatsState createState() => __PostStatsState();
}

class __PostStatsState extends State<_PostStats> {
  late int count;
  String? imgurl;
  String? path;
  late int countcmt;

  @override
  void initState() {
    super.initState();
    count = widget.post.like;
    countcmt = widget.post.commentcount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Palette.facebookBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_up,
                size: 10.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                count.toString(),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Text(
              countcmt.toString() + ' comments',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(width: 8.0),
            Text(
              '2 Shares',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            _PostButton(
              icon: Icon(MdiIcons.thumbUpOutline,
                  color: Colors.grey[600], size: 20.0),
              label: 'Like',
              onTap: () => like(widget.post.idpost, widget.email, context),
            ),
            _PostButton(
              icon: Icon(MdiIcons.commentOutline,
                  color: Colors.grey[600], size: 20.0),
              label: 'Comment',
              onTap: () => comment(widget.post.idpost, widget.email,
                  widget.post.idcomment, context),
            ),
            _PostButton(
              icon: Icon(MdiIcons.shareOutline,
                  color: Colors.grey[600], size: 25.0),
              label: 'Share',
              onTap: () => print("Share"),
            ),
          ],
        ),
      ],
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

  Future<void> comment(
      String id, String email, String idcomment, BuildContext context) async {
    String ip = MyApp.ipv4;
    final url = Uri.parse('$ip/api/commentcontent');
    String tokenData = await fetchCsrfToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokenData,
    };

    Map<String, dynamic> request = {
      "id": id,
      "email": email,
      "idcomment": idcomment
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> comments = responseData['Data'];
      print(comments);
      showComments(context, comments, id, email, idcomment);
    } else if (response.statusCode == 202) {
      showComments(context, [], id, email, idcomment);
    } else if (response.statusCode == 404) {
      thongbao('Post not found.');
    } else {
      print(response.statusCode);
      throw Exception("failed");
    }
  }

  void showComments(BuildContext context, List<dynamic> comments, String id,
      String email, String idcomment) {
    TextEditingController commentController = TextEditingController();
    String? imagePath;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> handleSendComment() async {
              String commentText = commentController.text;

              if (commentText.isEmpty && imagePath == null) {
                thongbao("Thêm nội dung");
                return;
              }

              String pathToSend = imagePath ?? "null";
              await sendComment(id, email, idcomment,
                  commentText.isEmpty ? "null" : commentText, pathToSend);

              commentController.clear();
              setState(() {
                imagePath = null; // Reset the image path
              });
            }

            return SingleChildScrollView(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: comments.isEmpty
                            ? Center(
                                child: Text(
                                  'Chưa có ai bình luận ở đây, hãy là người đầu tiên!',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        ProfileAvatar(
                                            imageUrl: comment['avatar']),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(comment['nameuser']),
                                        Expanded(
                                            child:
                                                Container()), // Fills the space between
                                        Text(
                                          getTimeAgo(comment['timecomment']),
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 30.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(comment['content']),
                                          if (comment['linkmedia'] != "null")
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        FullScreenImage(
                                                      imageUrl:
                                                          comment['linkmedia'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Hero(
                                                tag: comment['linkmedia'],
                                                child: Image.network(
                                                  comment['linkmedia'],
                                                  height: 100,
                                                  width: 100,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                if (imagePath != null)
                                  Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 8.0),
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Image.file(File(imagePath!)),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              imagePath = null;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                TextField(
                                  controller: commentController,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: "What's on your mind?",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              ImagePicker imagePicker = ImagePicker();
                              XFile? file = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (file == null) return;
                              setState(() {
                                imagePath = file.path;
                              });
                            },
                            icon: Icon(
                              Icons.photo_library,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: handleSendComment,
                            icon: Icon(
                              Icons.send,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getTimeAgo(String timeString) {
    DateTime time = DateTime.parse(timeString);
    DateTime now = DateTime.now()
        .subtract(Duration(hours: 7)); // Giảm giờ hiện tại 7 tiếng
    Duration difference = now.difference(time);

    if (difference.inDays > 0) {
      return DateFormat.yMd()
          .format(time); // Hiển thị ngày tháng năm nếu quá 1 ngày
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Future<void> like(String id, String email, BuildContext context) async {
    String ip = MyApp.ipv4;
    final url = Uri.parse('$ip/api/likecontent');
    String tokenData = await fetchCsrfToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': tokenData,
    };

    Map<String, dynamic> request = {"id": id};

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      setState(() {
        count += 1;
      });
    } else if (response.statusCode == 202) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String errorMessage = jsonResponse['message'];
      thongbao(errorMessage);
    } else if (response.statusCode == 404) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String errorMessage = jsonResponse['message'];
      thongbao(errorMessage);
    } else {
      print(response.statusCode);
      throw Exception("failed");
    }
  }

  Future<void> sendComment(String id, String email, String idcomment,
      String content, String? path) async {
    String ip = MyApp.ipv4;
    if (content == "null" && path == "null") {
      thongbao("Thêm nội dung");
      return;
    }

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFilename);
    imgurl = "null";
    try {
      if (path != "null") {
        await referenceImageToUpload.putFile(File(path!));
        imgurl = await referenceImageToUpload.getDownloadURL();
      }

      final url = Uri.parse("$ip/api/postcomment");
      String csrfToken = await fetchCsrfToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken
      };

      Map<String, dynamic> request = {
        "media": imgurl,
        "content": content,
        "email": email,
        "id": id,
        "idcomment": idcomment,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String message = jsonResponse['message'];
        setState(() {
          countcmt += 1;
        });
        thongbao(message);
      } else if (response.statusCode == 404) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String errorMessage = jsonResponse['message'];
        deleteImageFromStorage(imgurl!);
        thongbao(errorMessage);
      } else {
        throw Exception("Failed to post content");
      }
    } catch (error) {
      thongbao("Error: $error");
    }
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

class _PostButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback? onTap;

  const _PostButton(
      {Key? key, required this.icon, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            height: 25.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 4.0),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
