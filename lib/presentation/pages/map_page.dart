
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:task_assesment/data/models/location_point.dart';
import 'package:task_assesment/presentation/blocs/background_service/background_service_bloc.dart';
import 'package:task_assesment/presentation/blocs/location/location_bloc.dart';


/// Displays track visualization on an interactive map.
/// 
/// Features:
/// - Real-time location updates
/// - Path smoothing
/// - Track statistics
class MapPage extends StatefulWidget {
  final String? selectedTrackId;

  const MapPage({
    super.key,
    this.selectedTrackId,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  Timer? _updateTimer;
  Timer? _uiTimer;
  late AnimationController _controlsController;
  bool _showControls = true;
  Duration _currentDuration = Duration.zero;
  DateTime? _trackStartTime;

  @override
  void initState() {
    super.initState();
    _setupPeriodicUpdate();
    _controlsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controlsController.forward();
  }

  void _setupPeriodicUpdate() {
    // Location updates every 5 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final bgState = context.read<BackgroundServiceBloc>().state;
      if (bgState is BackgroundServiceRunning &&
          bgState.trackId == widget.selectedTrackId) {
        context.read<LocationBloc>().add(LocationHistoryUpdated());
      }
    });

    // UI updates every second for the timer
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final bgState = context.read<BackgroundServiceBloc>().state;
      if (bgState is BackgroundServiceRunning &&
          bgState.trackId == widget.selectedTrackId) {
        setState(() {
          if (_trackStartTime == null) {
            // Get the start time from the first location point
            final state = context.read<LocationBloc>().state;
            if (state is LocationDataLoaded) {
              final points = state.locationHistory
                  .where((p) => p.trackId == widget.selectedTrackId)
                  .toList();
              if (points.isNotEmpty) {
                _trackStartTime = points.first.timestamp;
              } else {
                _trackStartTime = DateTime.now();
              }
            }
          }
          _currentDuration = DateTime.now().difference(_trackStartTime ?? DateTime.now());
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsController.forward();
      } else {
        _controlsController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _uiTimer?.cancel();
    _controlsController.dispose();
    super.dispose();
  }

  List<LatLng> _smoothPoints(List<LocationPoint> points) {
    if (points.length < 3) {
      return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    }

    List<LatLng> smoothed = [];
    
    smoothed.add(LatLng(points.first.latitude, points.first.longitude));
    
    for (int i = 1; i < points.length - 1; i++) {
      final currPoint = points[i];
      final prevPoint = points[i - 1];
      final nextPoint = points[i + 1];
      
      final lat = (prevPoint.latitude + 2 * currPoint.latitude + nextPoint.latitude) / 4;
      final lng = (prevPoint.longitude + 2 * currPoint.longitude + nextPoint.longitude) / 4;
      
      smoothed.add(LatLng(lat, lng));
    }
    
    smoothed.add(LatLng(points.last.latitude, points.last.longitude));
    
    return smoothed;
  }

  double _calculateTotalDistance(List<LocationPoint> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance / 1000; // Convert to kilometers
  }

  Widget _buildStatsBar(List<LocationPoint> points) {
    if (points.isEmpty) return const SizedBox.shrink();

    final bgState = context.read<BackgroundServiceBloc>().state;
    final isLiveTracking = bgState is BackgroundServiceRunning &&
        bgState.trackId == widget.selectedTrackId;

    // Uses live duration for active tracking, otherwise use points duration
    final duration = isLiveTracking
        ? _currentDuration
        : points.last.timestamp.difference(points.first.timestamp);

    final distance = _calculateTotalDistance(points);
    final avgSpeed = duration.inSeconds > 0 
        ? distance / (duration.inSeconds / 3600)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.access_time,
              value: _formatDuration(duration),
              label: 'Duration',
            ),
            _StatItem(
              icon: Icons.speed,
              value: '${distance.toStringAsFixed(2)} km',
              label: 'Distance',
            ),
            _StatItem(
              icon: Icons.speed_outlined,
              value: '${avgSpeed.toStringAsFixed(2)} km/h',
              label: 'Avg Speed',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_controlsController),
          child: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withOpacity(0.9),
            elevation: 0,
            leading: BackButton(
              color: Theme.of(context).primaryColor,
            ),
            title: BlocBuilder<BackgroundServiceBloc, BackgroundServiceState>(
              builder: (context, state) {
                if (state is BackgroundServiceRunning &&
                    state.trackId == widget.selectedTrackId) {
                  return Row(
                    children: [
                      const Text('Live Tracking'),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                }
                return const Text('Track View');
              },
            ),
            actions: [
              BlocBuilder<BackgroundServiceBloc, BackgroundServiceState>(
                builder: (context, state) {
                  if (state is BackgroundServiceRunning &&
                      state.trackId == widget.selectedTrackId) {
                    return IconButton(
                      icon: const Icon(Icons.stop_circle),
                      onPressed: () {
                        context.read<BackgroundServiceBloc>().add(StopTracking());
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              if (state is LocationDataLoaded) {
                final points = state.locationHistory
                    .where((p) => p.trackId == widget.selectedTrackId)
                    .toList();

                if (points.isEmpty) {
                  return const Center(
                    child: Text('No points recorded yet'),
                  );
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      points.last.latitude,
                      points.last.longitude,
                    ),
                    initialZoom: 16,
                    onTap: (_, __) => _toggleControls(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: NetworkTileProvider(),
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _smoothPoints(points),
                          color: Colors.blue,
                          strokeWidth: 4,
                          borderStrokeWidth: 0,
                          borderColor: Colors.transparent,
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            points.first.latitude,
                            points.first.longitude,
                          ),
                          child: const Icon(
                            Icons.trip_origin,
                            color: Colors.green,
                          ),
                        ),
                        Marker(
                          point: LatLng(
                            points.last.latitude,
                            points.last.longitude,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 120,
            child: BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) {
                if (state is LocationDataLoaded) {
                  final points = state.locationHistory
                      .where((p) => p.trackId == widget.selectedTrackId)
                      .toList();

                  if (points.isNotEmpty) {
                    return Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'toggleControls',
                          mini: true,
                          onPressed: _toggleControls,
                          child: Icon(_showControls ? Icons.unfold_less : Icons.unfold_more),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'location',
                          onPressed: () {
                            _mapController.move(
                              LatLng(
                                points.last.latitude,
                                points.last.longitude,
                              ),
                              16,
                            );
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ],
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_controlsController),
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationDataLoaded) {
              final points = state.locationHistory
                  .where((p) => p.trackId == widget.selectedTrackId)
                  .toList();
              return _buildStatsBar(points);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    }
    return '${duration.inSeconds}s';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

