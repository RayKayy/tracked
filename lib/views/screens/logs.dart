import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracked/views/widgets/logs_list/all.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracked/constants/localstore_collections.dart';

class LogsRoute extends StatefulWidget {
  const LogsRoute({Key? key}) : super(key: key);

  @override
  State<LogsRoute> createState() => _LogsRouteState();
}

class _LogsRouteState extends State<LogsRoute> {
  final _db = Localstore.instance;

  _deleteLogs() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String dbFullPath =
        '$appDocPath${_db.collection(Collections.positions).path}';
    Directory dbDir = Directory(dbFullPath);
    if (dbDir.existsSync()) {
      await Directory(dbFullPath).delete(recursive: true);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Logs'),
          actions: [
            IconButton(onPressed: _deleteLogs, icon: const Icon(Icons.delete))
          ],
        ),
        body: FutureBuilder(
          future: _db.collection(Collections.positions).get(),
          initialData: const {},
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('No Logs Found'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final List<Position> positions = [];
            Map.from(snapshot.data).forEach(
                (key, value) => positions.add(Position.fromMap(value)));
            positions.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
            return LogsList(positions: positions);
          },
        ));
  }
}
