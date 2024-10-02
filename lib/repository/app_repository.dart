// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart';
//
// import '../utills/app_utils.dart';
//
// class AppRepository {
//   Future<http.Response> appPostRequest(Map<String, dynamic> data, String apiUrl,
//       {String accessToken = '',
//       String accessPIN = '',
//       String refreshToken = ''}) async {
//     print(apiUrl);
//     print(apiUrl);
//
//     var headers = {
//       'x-access-token': accessToken,
//       'x-access-pin': accessPIN,
//       'x-refresh-token': refreshToken,
//       'Content-Type': 'application/json'
//     };
//     print(data);
//     print(headers);
//     var body = jsonEncode(data);
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: headers,
//       body: body,
//     );
//     print(apiUrl);
//     print(response);
//     return response;
//   }
//
//
//
//   Future<http.Response> appPostRequestWithSingleImages(
//       Map<String, dynamic> data, String apiUrl, XFile? image,
//       {String accessToken = '',
//         String accessPIN = '',
//         String refreshToken = ''}) async {
//
//     // Initialize headers
//     var headers = {
//       'x-access-token': accessToken,
//       'x-access-pin': accessPIN,
//       'x-refresh-token': refreshToken,
//     };
//
//     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//     request.headers.addAll(headers);
//
//     // Add data fields to the request
//     data.forEach((key, value) {
//       request.fields[key] = value.toString();
//     });
//
//     // If an image is provided, add it to the request
//     if (image != null) {
//       // Detect MIME type of the image
//       String? mimeType = lookupMimeType(image.path);
//
//       if (mimeType == null) {
//         print("Unable to detect MIME type.");
//         return http.Response('Unable to detect MIME type', 400);
//       }
//
//       // Split MIME type into its type and subtype
//       var mimeTypeData = mimeType.split('/');
//
//       // Attach the image file with its detected content type
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'images',
//           image.path,
//           contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
//         ),
//       );
//     }
//
//     // Send the request
//     var streamedResponse = await request.send();
//     var response = await http.Response.fromStream(streamedResponse);
//
//     // Log response details
//     AppUtils().debuglog('Response Status Code: ${response.statusCode}');
//     AppUtils().debuglog('Response Body: ${response.body}');
//
//     return response;
//   }Future<http.Response> appPutRequestWithSingleImages(
//       Map<String, dynamic> data, String apiUrl, XFile? image,
//       {String accessToken = '',
//         String accessPIN = '',
//         String refreshToken = ''}) async {
//
//     // Initialize headers
//     var headers = {
//       'x-access-token': accessToken,
//       'x-access-pin': accessPIN,
//       'x-refresh-token': refreshToken,
//     };
//
//     var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
//     request.headers.addAll(headers);
//
//     // Add data fields to the request
//     data.forEach((key, value) {
//       request.fields[key] = value.toString();
//     });
//
//     // If an image is provided, add it to the request
//     if (image != null) {
//       // Detect MIME type of the image
//       String? mimeType = lookupMimeType(image.path);
//
//       if (mimeType == null) {
//         print("Unable to detect MIME type.");
//         return http.Response('Unable to detect MIME type', 400);
//       }
//
//       // Split MIME type into its type and subtype
//       var mimeTypeData = mimeType.split('/');
//
//       // Attach the image file with its detected content type
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'profileImage',
//           image.path,
//           contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
//         ),
//       );
//     }
//
//     // Send the request
//     var streamedResponse = await request.send();
//     var response = await http.Response.fromStream(streamedResponse);
//
//     // Log response details
//     AppUtils().debuglog('Response Status Code: ${response.statusCode}');
//     AppUtils().debuglog('Response Body: ${response.body}');
//
//     return response;
//   }
//
//   // Future<http.Response> appPostRequestWithImage(
//   //     Map<String, dynamic> data, String apiUrl,
//   //     {String accessToken = '',
//   //     String accessPIN = '',
//   //     String refreshToken = ''}) async {
//   //   print(apiUrl);
//   //   print(apiUrl);
//   //
//   //   var headers = {
//   //     'x-access-token': accessToken,
//   //     'x-access-pin': accessPIN,
//   //     'x-refresh-token': refreshToken,
//   //     'Content-Type': 'application/json'
//   //   };
//   //   print(data);
//   //   print(headers);
//   //   var body = jsonEncode(data);
//   //   final response = await http.post(
//   //     Uri.parse(apiUrl),
//   //     headers: headers,
//   //     body: body,
//   //   );
//   //   print(apiUrl);
//   //   print(response);
//   //   return response;
//   // }
//
//   Future<http.Response> appPutRequest(Map<String, dynamic> data, String apiUrl,
//       {String accessToken = '',
//       String accessPIN = '',
//       String refreshToken = ''}) async {
//     print(apiUrl);
//     print(apiUrl);
//
//     var headers = {
//       'x-access-token': accessToken,
//       'x-access-pin': accessPIN,
//       'x-refresh-token': refreshToken,
//       'Content-Type': 'application/json'
//     };
//     print(data);
//     print(headers);
//     var body = jsonEncode(data);
//     final response = await http.put(
//       Uri.parse(apiUrl),
//       headers: headers,
//       body: body,
//     );
//     print(apiUrl);
//     print(response);
//     return response;
//   }
//
//   Future<http.Response> appGetRequest(String apiUrl,
//       {String accessToken = '',
//       String accessPIN = '',
//       String refreshToken = ''}) async {
//     //print(98765456789);
//     var headers = {
//       'x-access-token': accessToken,
//       'x-access-pin': accessPIN,
//       'x-refresh-token': refreshToken,
//       'Content-Type': 'application/json'
//     };
//     print(headers);
//     print(apiUrl);
//     final response = await http.get(
//       Uri.parse(apiUrl),
//       headers: headers,
//     );
//     print(apiUrl);
//     print(response);
//     return response;
//   }
//
//   Future<http.Response> appDeleteRequest(String apiUrl,
//       {String accessToken = '',
//       String accessPIN = '',
//       String refreshToken = ''}) async {
//     //print(98765456789);
//     var headers = {
//       'x-access-token': accessToken,
//       'x-access-pin': accessPIN,
//       'x-refresh-token': refreshToken,
//       'Content-Type': 'application/json'
//     };
//     print(headers);
//     print(apiUrl);
//     final response = await http.delete(
//       Uri.parse(apiUrl),
//       headers: headers,
//     );
//     print(apiUrl);
//     print(response);
//     return response;
//   }
// }
