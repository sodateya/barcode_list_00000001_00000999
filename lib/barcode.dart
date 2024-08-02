import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class BarcodeWrapView extends StatelessWidget {
  const BarcodeWrapView({super.key, required this.items});
  final List<Map<String, String>> items;

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
            for (final item in items)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 100,
                      child: BarcodeWidget(
                        barcode: Barcode.code39(), // Barcode type and settings
                        data: item['barcode']!, // Barcode data
                        width: 200,
                        height: 100,
                      ),
                    ),
                    Text(
                      item['name']!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ), // Item name
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
