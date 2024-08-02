import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:barcode_list/barcode.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'バーコード発行',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BarcodeReaderExample(),
    );
  }
}

class BarcodeReaderExample extends StatefulWidget {
  const BarcodeReaderExample({super.key});

  @override
  _BarcodeReaderExampleState createState() => _BarcodeReaderExampleState();
}

class _BarcodeReaderExampleState extends State<BarcodeReaderExample> {
  List<Map<String, String>> _barcodesAndNames = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String? path = result.files.single.path;

      if (path != null) {
        List<Map<String, String>> barcodesAndNames = await _loadJSON(path);
        setState(() {
          _barcodesAndNames = barcodesAndNames;
        });
      }
    }
  }

  Future<List<Map<String, String>>> _loadJSON(String path) async {
    final file = File(path);
    final jsonString = await file.readAsString(encoding: utf8);
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    return (jsonData['data'] as List).map((entry) {
      return {
        'barcode': entry['barcode'].toString().trim(),
        'name': entry['name'].toString().trim()
      };
    }).toList();
  }

  Future<void> _printBarcodes() async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final doc = pw.Document();
    final barcodeWidgets = <pw.Widget>[];

    for (final item in _barcodesAndNames) {
      barcodeWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Column(
            children: [
              pw.Container(
                width: 200,
                height: 100,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code39(), // Barcode type and settings
                  data: item['barcode']!, // Barcode data
                  width: 200,
                  height: 100,
                  textStyle: pw.TextStyle(font: ttf),
                ),
              ),
              pw.Text(item['name']!,
                  style: pw.TextStyle(font: ttf)), // Item name
            ],
          ),
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Wrap(
            spacing: 8.0, // 横方向の間隔
            runSpacing: 8.0, // 縦方向の間隔
            children: barcodeWidgets,
          )
        ],
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("バーコード発行"),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _pickFile,
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _printBarcodes,
            ),
          ],
        ),
        body: _barcodesAndNames.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('JSONファイルを選択してください')),
                  ),
                  TextButton(
                      onPressed: _pickFile, child: const Text('JSONファイルを選択'))
                ],
              )
            : BarcodeWrapView(
                items: _barcodesAndNames,
              ));
  }
}
