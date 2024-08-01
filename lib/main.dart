import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:barcode_list/barcode.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  List<String> _barcodes = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String? path = result.files.single.path;

      if (path != null) {
        List<String> barcodes = await _loadCSV(path);
        setState(() {
          _barcodes = barcodes;
        });
      }
    }
  }

  Future<List<String>> _loadCSV(String path) async {
    final file = File(path).openRead();
    final data = await file
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .toList();

    return data.map((line) => line.trim()).toList();
  }

  Future<void> _printBarcodes() async {
    final doc = pw.Document();
    final barcodeWidgets = <pw.Widget>[];

    for (final code in _barcodes) {
      barcodeWidgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Container(
            width: 200,
            height: 100,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code39(), // Barcode type and settings
              data: code, // Content
              width: 200,
              height: 100,
            ),
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
        body: _barcodes.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('csvファイルを選択してください')),
                  ),
                  TextButton(
                      onPressed: _pickFile, child: const Text('csvファイルを選択'))
                ],
              )
            : BarcodeWrapView(
                numberList: _barcodes,
              ));
  }
}
