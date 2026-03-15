import 'package:flutter/material.dart';
import '../constants/texts.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: const Center(
        child: Text(AppTexts.goHistory),
      ),
    );
  }
}
