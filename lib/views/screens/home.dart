import 'package:flutter/material.dart';

import 'package:tracked/views/widgets/location_tracker.dart';
import 'package:tracked/views/screens/logs.dart';

class HomeRoute extends StatelessWidget {
  const HomeRoute({Key? key}) : super(key: key);

  _navigateToLogs(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LogsRoute()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: [
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: () => _navigateToLogs(context),
          tooltip: 'Saved Suggestions',
        ),
      ]),
      body: const LocationTracker(),
    );
  }
}
