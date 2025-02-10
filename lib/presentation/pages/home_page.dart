
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assesment/data/models/location_point.dart';
import 'package:task_assesment/presentation/blocs/background_service/background_service_bloc.dart';
import 'package:task_assesment/presentation/blocs/location/location_bloc.dart';
import 'package:task_assesment/presentation/pages/map_page.dart';


/// Main screen of the application displaying track history and current tracking status.
/// 
/// Features:
/// - Displays active tracking status
/// - Shows track history
/// - Provides track management options
/// - Navigation to map view
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    context.read<LocationBloc>().add(LocationHistoryUpdated());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text(
          'Location Tracks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearTracksDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<LocationBloc>().add(LocationHistoryUpdated());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildTrackingStatus(),
              BlocBuilder<LocationBloc, LocationState>(
                builder: (context, state) {
                  if (state is LocationDataLoaded) {
                    return _buildTracksList(context, state.locationHistory);
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingStatus() {
    return BlocBuilder<BackgroundServiceBloc, BackgroundServiceState>(
      builder: (context, state) {
        if (state is BackgroundServiceRunning) {
          return _ActiveTrackingCard(trackId: state.trackId);
        } else if (state is BackgroundServiceError) {
          return _ErrorCard(message: state.message);
        } else if (state is BackgroundServiceStopped) {
          return const _StartTrackingCard();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTracksList(BuildContext context, List<LocationPoint> locationHistory) {
    final tracks = groupBy(
      locationHistory,
      (LocationPoint p) => p.trackId,
    );

    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tracks recorded yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your location',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tracks.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final trackId = tracks.keys.elementAt(index);
        final points = tracks[trackId]!;
        return _TrackCard(
          trackId: trackId,
          points: points,
          onTap: () => _navigateToMap(context, trackId),
        );
      },
    );
  }

  void _navigateToMap(BuildContext context, String? trackId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(selectedTrackId: trackId),
      ),
    );
  }

  Future<void> _showClearTracksDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all tracks?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<LocationBloc>().add(ClearAllTracks());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ActiveTrackingCard extends StatelessWidget {
  final String trackId;

  const _ActiveTrackingCard({required this.trackId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha : 0.8),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPage(selectedTrackId: trackId),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.directions_run,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Currently Tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle, color: Colors.white),
                        onPressed: () {
                          context.read<BackgroundServiceBloc>().add(StopTracking());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Track ID: ${trackId.substring(0, 8)}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to view live tracking',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartTrackingCard extends StatelessWidget {
  const _StartTrackingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<BackgroundServiceBloc>().add(StartTracking());
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Tracking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Begin recording your location',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final String trackId;
  final List<LocationPoint> points;
  final VoidCallback onTap;

  const _TrackCard({
    required this.trackId,
    required this.points,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstPoint = points.first;
    final lastPoint = points.last;
    final duration = lastPoint.timestamp.difference(firstPoint.timestamp);
    final pointCount = points.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.route,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Track ${trackId.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: lastPoint.isOnline ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.access_time,
                    label: _formatDuration(duration),
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.location_on,
                    label: '$pointCount points',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(firstPoint.timestamp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

