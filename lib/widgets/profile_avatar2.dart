import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socialmediaapp/config/palette.dart';

class ProfileAvatar2 extends StatelessWidget {
  final String imageUrl;
  final bool isActive;
  final bool hasBorder;
  const ProfileAvatar2({
    Key? key,
    required this.imageUrl,
    this.hasBorder = false,
    this.isActive = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 30.0,
          backgroundColor: Palette.facebookBlue,
          child: CircleAvatar(
            radius: hasBorder ? 47.0 : 50.0,
            backgroundColor: Colors.grey[200],
            backgroundImage: CachedNetworkImageProvider(imageUrl),
          ),
        ),
        isActive
            ? Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                      color: Palette.online,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2.0,
                        color: Colors.white,
                      )),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
