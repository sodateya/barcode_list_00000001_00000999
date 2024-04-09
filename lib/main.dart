import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: BarcodeWrapView()),
      ),
    );
  }
}

class BarcodeWrapView extends StatelessWidget {
  List<String> numberList = List.generate(999, (index) {
    int number = index + 1;
    String formattedNumber = number.toString().padLeft(8, '0');
    return formattedNumber;
  });
  BarcodeWrapView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2894,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0, // 横方向の間隔
          runSpacing: 8.0, // 縦方向の間隔
          children: [
            for (final code in numberList)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: BarcodeWidget(
                    barcode: Barcode.code39(), // Barcode type and settings
                    data: code, // Content
                    width: 200,
                    height: 100,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
