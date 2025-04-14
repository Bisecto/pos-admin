import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/product_model.dart';

class ExcelExporter {
  /// Export any list of objects to Excel
  /// - `items`: List of objects to export (can be any model type)
  /// - `fileName`: Name of the exported file (without extension)
  /// - `toJson`: Function that converts your model to a Map
  /// - `customHeaders`: Optional custom headers for the Excel columns
  /// - `includeFields`: Optional list of fields to include (if not specified, all fields are included)
  /// - `excludeFields`: Optional list of fields to exclude
  static Future<void> exportToExcel<T>({
    required BuildContext context,
    required List<T> items,
    required String fileName,
    required Map<String, dynamic> Function(T item) toJson,
    List<String>? customHeaders,
    List<String>? includeFields,
    List<String>? excludeFields,
  }) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    try {
      // Create a new Excel document
      final excel = Excel.createExcel();
      excel.delete('Sheet1');

      final Sheet sheet = excel[fileName];

      // Convert first item to map to determine fields
      final Map<String, dynamic> sampleItemMap = toJson(items.first);
      print('Sample item map: $sampleItemMap');

      // Determine which fields to include in the export
      List<String> fields = sampleItemMap.keys.toList();

      // Filter fields if needed
      if (includeFields != null && includeFields.isNotEmpty) {
        fields = fields.where((field) => includeFields.contains(field)).toList();
      }

      if (excludeFields != null && excludeFields.isNotEmpty) {
        fields = fields.where((field) => !excludeFields.contains(field)).toList();
      }

      // Use custom headers if provided, otherwise use field names
      final List<String> headers = customHeaders ?? fields;

      // Ensure headers and fields have the same length
      if (customHeaders != null && headers.length != fields.length) {
        throw Exception('Custom headers length must match the number of fields being exported');
      }

      // Add headers to the first row with bold formatting
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i].toUpperCase());

        // Apply bold formatting to headers
        final cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
        cell.cellStyle = cellStyle;
      }

      // Add data rows
      for (var rowIndex = 0; rowIndex < items.length; rowIndex++) {
        final item = items[rowIndex];
        final Map<String, dynamic> itemMap = toJson(item);

        // Add each field value to its corresponding column
        for (var colIndex = 0; colIndex < fields.length; colIndex++) {
          final field = fields[colIndex];
          final value = itemMap[field];
          final cell = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex + 1
          ));

          // Handle different value types
          if (value == null) {
            cell.value = TextCellValue('');
          } else if (value is num) {
            cell.value = DoubleCellValue(value.toDouble());
          } else if (value is bool) {
            cell.value = BoolCellValue(value);
          } else if (value is DateTime) {
            cell.value = DateTimeCellValue(
              year: value.year,
              month: value.month,
              day: value.day,
              hour: value.hour,
              minute: value.minute,
            );
          } else if (value is Timestamp) {
            final dt = value.toDate();
            cell.value = DateTimeCellValue(
              year: dt.year,
              month: dt.month,
              day: dt.day,
              hour: dt.hour,
              minute: dt.minute,
            );
          } else {
            // Convert to string for all other types
            cell.value = TextCellValue(value.toString().toUpperCase());
          }
        }
      }

      // Auto-fit column widths
      for (var i = 0; i < fields.length; i++) {
        // This is a simplistic approach - the excel package doesn't have built-in auto-fit
        // So we're setting reasonable default widths
        sheet.setColumnWidth(i, 15.0);
      }

      // Generate the Excel file
      final List<int>? bytes = excel.encode();

      if (bytes != null) {
        try {
          // Get temporary directory (no permissions needed)
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$fileName.xlsx';

          // Save to temp directory
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          // Show loading indicator
          _showLoadingDialog(context);

          // Share the file
          await Share.shareXFiles(
              [XFile(filePath)],
              subject: '$fileName Export',
              text: 'Exported data from your app'
          ).then((_) {
            // Dismiss loading dialog
            Navigator.of(context, rootNavigator: true).pop();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Excel file exported successfully')),
            );
          });
        } catch (e) {
          // Handle any errors during file operations
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving file: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      // Handle any errors during Excel creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting to Excel: ${e.toString()}')),
      );
    }
  }

  // Helper method to show a loading dialog
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Preparing Excel file..."),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Example Usage

// 1. Define your model class with toJson method

// 2. Example implementation in a widget
