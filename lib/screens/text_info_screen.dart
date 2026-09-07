import 'package:flutter/material.dart';

class TextInfoScreen extends StatelessWidget {
  const TextInfoScreen({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(body, style: const TextStyle(fontSize: 15.5, height: 1.65)),
            ),
          ),
        ],
      ),
    );
  }
}
