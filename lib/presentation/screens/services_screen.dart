import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SharedAppBar(
        title: 'Services',
      ),
      body: Center(
        child: Text('Services Coming Soon'),
      ),
    );
  }
}
