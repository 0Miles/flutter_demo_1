class ClockRecord {
  final String? time;
  final bool isGps;
  final bool isPending;

  ClockRecord({
    required this.time,
    required this.isGps,
    required this.isPending,
  });

  factory ClockRecord.fromJson(Map<String, dynamic> json) {
    return ClockRecord(
      time: json['time'],
      isGps: json['is_gps'] ?? false,
      isPending: json['is_pending'] ?? false,
    );
  }
}