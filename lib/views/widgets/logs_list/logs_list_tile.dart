import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LogsListTile extends StatelessWidget {
  const LogsListTile({
    Key? key,
    required this.position,
  }) : super(key: key);

  final Position position;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(position.toString()),
      subtitle: Text(position.timestamp.toString()),
      tileColor: Colors.white,
    );
  }
}
