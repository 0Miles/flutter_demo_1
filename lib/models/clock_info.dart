import 'clock_record.dart';

class ClockInfo {
  final bool shouldDisplay;
  final bool hasInoutPermission;
  final bool showInoutButton;
  final bool isPunchButtonEnabled;
  final bool isGpsEnabled;
  final bool isIpEnabled;
  final ClockRecord? clockIn;
  final ClockRecord? clockOut;
  final String? signInTime;
  final String? signOutTime;
  final String datetime;

  ClockInfo({
    required this.shouldDisplay,
    required this.hasInoutPermission,
    required this.showInoutButton,
    required this.isPunchButtonEnabled,
    required this.isGpsEnabled,
    required this.isIpEnabled,
    this.clockIn,
    this.clockOut,
    this.signInTime,
    this.signOutTime,
    required this.datetime,
  });

  factory ClockInfo.fromJson(Map<String, dynamic> json) {
    return ClockInfo(
      shouldDisplay: json['should_display'] ?? false,
      hasInoutPermission: json['has_inout_permission'] ?? false,
      showInoutButton: json['show_inout_button'] ?? false,
      isPunchButtonEnabled: json['is_punch_button_enabled'] ?? false,
      isGpsEnabled: json['is_gps_enabled'] ?? false,
      isIpEnabled: json['is_ip_enabled'] ?? false,
      clockIn: json['clock_in'] != null ? ClockRecord.fromJson(json['clock_in']) : null,
      clockOut: json['clock_out'] != null ? ClockRecord.fromJson(json['clock_out']) : null,
      signInTime: json['sign_in_time'],
      signOutTime: json['sign_out_time'],
      datetime: json['datetime'] ?? '',
    );
  }
}