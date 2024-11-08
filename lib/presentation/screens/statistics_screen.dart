import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SharedAppBar(
        title: 'Statistics',
      ),
      body: Center(
        child: Text('Statistics Coming Soon'),
      ),
    );
  }
}
