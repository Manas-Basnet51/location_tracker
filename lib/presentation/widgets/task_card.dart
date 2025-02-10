import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assesment/data/models/location_point.dart';

class TrackCard extends StatelessWidget {
  final String trackId;
  final List<LocationPoint> points;
  final VoidCallback onTap;

  const TrackCard({
    super.key,
    required this.trackId,
    required this.points,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = points.first.timestamp;
    final endTime = points.last.timestamp;
    final duration = endTime.difference(startTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Track ${trackId.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Started: ${DateFormat.yMMMd().add_jm().format(startTime)}'),
            Text('Duration: ${duration.inMinutes} minutes'),
            Text('Points: ${points.length}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}