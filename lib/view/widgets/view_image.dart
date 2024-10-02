import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  final String imageUrl;

  ImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Image'),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          //height: AppUtils.deviceScreenSize(context).width / 2,
          //width: AppUtils.deviceScreenSize(context).width,
        ),
      ),
    );
  }
}
