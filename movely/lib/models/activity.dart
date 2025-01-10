
class Activity {
  final String id;
  final String userId;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;
  final double distance;
  final int duration;
  final Map<String, dynamic> gpsData;

  Activity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.duration,
    required this.gpsData,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      userId: json['user_id'],
      activityType: json['activity_type'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      distance: json['distance'],
      duration: json['duration'],
      gpsData: json['gps_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'distance': distance,
      'duration': duration,
      'gps_data': gpsData,
    };
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? activityType,
    DateTime? startTime,
    DateTime? endTime,
    double? distance,
    int? duration,
    Map<String, dynamic>? gpsData,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      gpsData: gpsData ?? this.gpsData,
    );
  }
}
