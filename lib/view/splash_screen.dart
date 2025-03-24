import 'dart:typed_data';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../res/app_colors.dart';
import '../res/app_images.dart';
import '../utills/app_utils.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:io';
import 'package:image/image.dart' as img;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUtils appUtils = AppUtils();

  @override
  void initState() {
    appUtils.openApp(context);
    //updateAllProductsQty('8V8YTiKWyObO7tppMHeP');

    super.initState();
  }

  // Future<void> printLabel() async {
  //   final pdfData = await generateLabelPdf();
  //   await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
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

  // Future<void> printLabel(String printerIp, int printerPort) async {
  //   try {
  //     final profile = await CapabilityProfile.load();
  //     final printer = NetworkPrinter(PaperSize.mm58, profile);
  //
  //     final PosPrintResult connectResult =
  //     await printer.connect(printerIp, port: printerPort);
  //
  //     if (connectResult != PosPrintResult.success) {
  //       print("Failed to connect: $connectResult");
  //       return;
  //     }
  //
  //     // Store Name
  //     printer.text('COMPASS CLOTHING',
  //         styles: PosStyles(
  //             align: PosAlign.left,
  //             bold: true,
  //             height: PosTextSize.size1,
  //             width: PosTextSize.size1));
  //
  //     printer.hr(); // Horizontal Line
  //
  //     // Size and Price
  //     printer.text('Size: M',
  //         styles: PosStyles(align: PosAlign.left, height: PosTextSize.size1));
  //     printer.text('Price: NGN 5,000',
  //         styles: PosStyles(align: PosAlign.left, height: PosTextSize.size1));
  //
  //     printer.hr(); // Horizontal Line
  //
  //     // QR Code
  //     //printer.qrcode('https://compass.com', size: QRSize.Size4);
  //
  //     //printer.cut();
  //     printer.disconnect();
  //   } catch (e) {
  //     print("Error in printLabel: $e");
  //   }
  // }
  // Future<void> printReceipt() async {
  //   // Pairing with the printer
  //   await _printer.pairDevice(vendorId: 0x1fc9, productId: 0x2016);
  //
  //   // Print header
  //   await _printer.printText('---------------------------------', centerAlign: true);
  //   await _printer.printText('   COMPASS CLOTHING   ', bold: true, centerAlign: true);
  //   await _printer.printText('---------------------------------', centerAlign: true);
  //   await _printer.printEmptyLine();
  //
  //   // Print size and price
  //   await _printer.printText('      Size: M', centerAlign: true);
  //   await _printer.printText('   Price: NGN 5,000', centerAlign: true);
  //   await _printer.printEmptyLine();
  //
  //   // Print separator
  //   await _printer.printText('---------------------------------', centerAlign: true);
  //   await _printer.printEmptyLine();
  //
  //   // Print QR Code (assuming the printer supports it)
  //   await _printer.printBarcode('https://compass.com',);
  //   await _printer.printEmptyLine();
  //
  //   // Print footer
  //   await _printer.printText('---------------------------------', centerAlign: true);
  //
  //   // Close printer
  //   //await _printer.cut();
  //   await _printer.closePrinter();
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
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // TextStyles.textHeadings(
                  //     textValue: "CHECKPOINT ADMIN POS",
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
