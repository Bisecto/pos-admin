import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';
import '../model/plan_model.dart';
import '../res/app_colors.dart';
import '../res/app_images.dart';
import '../utills/app_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUtils appUtils = AppUtils();


  // Future<void> uploadPlansToFirebase() async {
  //   final plansRef = FirebaseFirestore.instance.collection('plans');
  //
  //   final plans = {
  //     'starter': Plan(
  //       name: 'Starter',
  //       monthlyPrice: 0,
  //       yearlyPrice: 0,
  //       maxProducts: 20,
  //       maxTransactionsPerMonth: 100,
  //       maxUsers: 1,
  //       receiptPrinting: true,
  //       cloudSync: false,
  //       exportProductsToExcel: false,
  //       printProductsA4: false,
  //       printTransactionsA4: false,
  //       exportTransactionsToExcel: false,
  //       printStaffA4: false,
  //       exportStaffToExcel: false,
  //       accessToMultiTerminal: false,
  //       offlineMode: true,
  //       customBranding: false,
  //       advancedRolesBranding: false,
  //       apiAccess: false,
  //       stockManagement: true,
  //       logs: false,
  //     ),
  //     'basic': Plan(
  //       name: 'Basic',
  //       monthlyPrice: 9.99,
  //       yearlyPrice: 99.99,
  //       maxProducts: 50,
  //       maxTransactionsPerMonth: 500,
  //       maxUsers: 3,
  //       receiptPrinting: true,
  //       cloudSync: true,
  //       exportProductsToExcel: true,
  //       printProductsA4: true,
  //       printTransactionsA4: true,
  //       exportTransactionsToExcel: true,
  //       printStaffA4: false,
  //       exportStaffToExcel: false,
  //       accessToMultiTerminal: true,
  //       offlineMode: true,
  //       customBranding: false,
  //       advancedRolesBranding: false,
  //       apiAccess: false,
  //       stockManagement: true,
  //       logs: false,
  //     ),
  //     'growth': Plan(
  //       name: 'Growth',
  //       monthlyPrice: 24.99,
  //       yearlyPrice: 249.99,
  //       maxProducts: 5000,
  //       maxTransactionsPerMonth: 10000,
  //       maxUsers: 10,
  //       receiptPrinting: true,
  //       cloudSync: true,
  //       exportProductsToExcel: true,
  //       printProductsA4: true,
  //       printTransactionsA4: true,
  //       exportTransactionsToExcel: true,
  //       printStaffA4: true,
  //       exportStaffToExcel: true,
  //       accessToMultiTerminal: true,
  //       offlineMode: true,
  //       customBranding: true,
  //       advancedRolesBranding: true,
  //       apiAccess: false,
  //       stockManagement: true,
  //       logs: true,
  //     ),
  //     'enterprise': Plan(
  //       name: 'Enterprise',
  //       monthlyPrice: 49.99,
  //       yearlyPrice: 499.99,
  //       maxProducts: -1,
  //       maxTransactionsPerMonth: -1,
  //       maxUsers: -1,
  //       receiptPrinting: true,
  //       cloudSync: true,
  //       exportProductsToExcel: true,
  //       printProductsA4: true,
  //       printTransactionsA4: true,
  //       exportTransactionsToExcel: true,
  //       printStaffA4: true,
  //       exportStaffToExcel: true,
  //       accessToMultiTerminal: true,
  //       offlineMode: true,
  //       customBranding: true,
  //       advancedRolesBranding: true,
  //       apiAccess: true,
  //       stockManagement: true,
  //       logs: true,
  //     ),
  //   };
  //
  //   for (final entry in plans.entries) {
  //     await plansRef.doc(entry.key).set(entry.value.toJson());
  //     print("Uploaded ${entry.key} plan");
  //   }
  // }

  @override
  void initState() {
   // uploadPlansToFirebase();

    appUtils.openApp(context);
    //updateAllProductsQty('8V8YTiKWyObO7tppMHeP');

    super.initState();
  }

  // Future<void> printLabel() async {
  //   final String labelHtml = """
  //   <html>
  //   <head>
  //     <style>
  //       @page { size: 60mm 40mm; margin: 0; }
  //       body { font-family: Arial, sans-serif; font-size: 12px; text-align: center; margin: 0; padding: 0; }
  //       .label { width: 60mm; height: 40mm; display: flex; flex-direction: column; justify-content: center; align-items: center; }
  //       .company { font-size: 14px; font-weight: bold; }
  //       .product { font-size: 12px; font-weight: bold; }
  //       .price { font-size: 14px; font-weight: bold; margin: 5px 0; }
  //       .size { font-size: 12px; }
  //     </style>
  //   </head>
  //   <body>
  //     <div class="label">
  //       <div class="company">Nenny Stitches</div>
  //       <div class="product">Adunni pant</div>
  //       <div class="price">200,000</div>
  //       <div class="size">Size: Meduim</div>
  //     </div>
  //   </body>
  //   </html>
  //   """;
  //   final printWindow = web.window.open('', '_blank');
  //   if (printWindow != null) {
  //     printWindow.document.write(labelHtml.toJS);
  //     printWindow.document.close();
  //   }
  // }
  // Future<Uint8List> generateLabelPdf() async {
  //   final pdf = pw.Document();
  //
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat(60 * PdfPageFormat.mm, 35 * PdfPageFormat.mm),
  //       build: (pw.Context context) {
  //         return pw.Container(
  //           padding: const pw.EdgeInsets.all(4),
  //           decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               pw.Text('COMPASS CLOTHING',
  //                   style: pw.TextStyle(
  //                       fontSize: 10, fontWeight: pw.FontWeight.bold)),
  //               pw.Divider(),
  //               pw.Text('Size: M', style: pw.TextStyle(fontSize: 10)),
  //               pw.Text('Price: NGN 5,000', style: pw.TextStyle(fontSize: 10)),
  //               pw.Divider(),
  //               pw.Center(
  //                 child: pw.BarcodeWidget(
  //                   barcode: pw.Barcode.qrCode(),
  //                   data: 'https://compass.com',
  //                   width: 40,
  //                   height: 40,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  //
  //   return pdf.save();
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: Center(
          child: Container(
            // height: AppUtils.deviceScreenSize(context).height,
            // width: AppUtils.deviceScreenSize(context).width,
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBackgroundColor,

              // image: DecorationImage(image: AssetImage(AppImages.splashLogo,),fit: BoxFit.fill)
            ),
            child: GestureDetector(
              onTap: () {
                //printLabel();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.companyLogo,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // TextStyles.textHeadings(
                  //     textValue: "SALE ON SPOT",
                  //     textSize: 20,
                  //     textColor: AppColors.white)
                ],
              ),
            ),
          ),
        ));
  }

// Future<void> printImageLabel(String printerIp, int printerPort, String imagePath) async {
//   try {
//     final profile = await CapabilityProfile.load();
//     final printer = NetworkPrinter(PaperSize.mm58, profile);
//
//     final PosPrintResult connectResult = await printer.connect(printerIp, port: printerPort);
//
//     if (connectResult != PosPrintResult.success) {
//       print("Failed to connect: $connectResult");
//       return;
//     }
//
//     // Load the image
//     final File file = File(imagePath);
//     final List<int> bytes = await file.readAsBytes();
//     final img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
//
//     if (image != null) {
//       printer.image(image);
//      // printer.cut();
//     } else {
//       print("Error: Could not decode image.");
//     }
//
//     printer.disconnect();
//   } catch (e) {
//     print("Error in printImageLabel: $e");
//   }
// }
//
// Future<void> printGeneratedLabel(String printerIp, int printerPort) async {
//   String imagePath = await generateLabelImage();
//   await printImageLabel(printerIp, printerPort, imagePath);
// }
// Future<String> generateLabelImage() async {
//   final recorder = ui.PictureRecorder();
//   final canvas = Canvas(recorder);
//
//   // Define the label size as 60x35mm → 480x280 pixels
//   final size = Size(480, 280);
//   final painter = LabelPainter();
//   painter.paint(canvas, size);
//
//   final picture = recorder.endRecording();
//   final img = await picture.toImage(size.width.toInt(), size.height.toInt());
//   final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//   final buffer = byteData!.buffer.asUint8List();
//
//   final directory = await getTemporaryDirectory();
//   final filePath = '${directory.path}/label.png';
//   final file = File(filePath);
//   await file.writeAsBytes(buffer);
//
//   return filePath;
// }
}

// class LabelPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.black;
//     final textStyle = TextStyle(
//       color: Colors.black,
//       fontSize: 40, // Larger for better printing
//       fontWeight: FontWeight.bold,
//     );
//     final smallTextStyle = TextStyle(
//       color: Colors.black,
//       fontSize: 35, // Smaller text
//     );
//
//     final textPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//     );
//
//     double yOffset = 30; // Initial position
//
//     // Draw Store Name
//     textPainter.text = TextSpan(text: 'COMPASS CLOTHING', style: textStyle);
//     textPainter.layout();
//     textPainter.paint(canvas, Offset(20, yOffset));
//     yOffset += 70; // Move down
//
//     // Draw Horizontal Line
//     canvas.drawLine(Offset(20, yOffset), Offset(size.width - 20, yOffset), paint);
//     yOffset += 40;
//
//     // Draw Size
//     textPainter.text = TextSpan(text: 'Size: M', style: smallTextStyle);
//     textPainter.layout();
//     textPainter.paint(canvas, Offset(20, yOffset));
//     yOffset += 50;
//
//     // Draw Price
//     textPainter.text = TextSpan(text: 'Price: NGN 5,000', style: smallTextStyle);
//     textPainter.layout();
//     textPainter.paint(canvas, Offset(20, yOffset));
//     yOffset += 50;
//
//     // Draw Another Horizontal Line
//     canvas.drawLine(Offset(20, yOffset), Offset(size.width - 20, yOffset), paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
