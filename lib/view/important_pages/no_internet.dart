// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../res/app_colors.dart';
//
// class No_internet_Page extends StatelessWidget {
//   const No_internet_Page({
//     Key? key,
//     required this.onRetry,
//   }) : super(key: key);
//   final Function() onRetry;
//
//   //final bool reInitApp;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//        //crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Image.asset(
//             AppImages.signa,
//             height: 150,
//             width: 150,
//           ),
//            const SizedBox(height: 20,),
//
//            // padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
//             const CustomText(
//               text:'Trouble connecting with\nthe internet',
//               maxLines: 2,
//               textAlign: TextAlign.center,
//
//             ),
//           const SizedBox(height: 20,),
//
//           GestureDetector(onTap:(){ onRetry();},child: SvgPicture.asset(AppIcons.refresh)),
//
//
//         ],
//       ),
//     );
//   }
// }
