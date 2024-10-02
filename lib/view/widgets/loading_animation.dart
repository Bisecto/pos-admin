import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../res/app_colors.dart';



class LoadingDialog extends StatelessWidget {
  final String title;

  const LoadingDialog(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        // The background color
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
              // The loading indicator
              Container(
                color: Colors.transparent,
                height: 70,
                child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.darkGreen,
                      size: 100,
                    )),
              ),
              const SizedBox(height: 10),

              DefaultTextStyle(
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    backgroundColor: Colors.transparent,
                    fontSize: 15
                ),
                child: Text(
                  title,
                  softWrap: true,
                  textAlign: TextAlign.center,

                ),
              )
            ],
          ),
        ),
      ),
    );

  }
}