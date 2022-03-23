import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracked/views/widgets/logs_list/logs_list_tile.dart';

class LogsList extends StatelessWidget {
  const LogsList({Key? key, required this.positions}) : super(key: key);

  final List<Position> positions;

  Widget _listTileBuilder(BuildContext context, int i) {
    return LogsListTile(position: positions[i]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: positions.length,
      itemBuilder: _listTileBuilder,
      separatorBuilder: (BuildContext context, int index) => const Divider(
        thickness: 1,
        height: 1,
      ),
    );
  }
}
