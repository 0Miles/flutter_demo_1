import 'package:flutter/material.dart';
import 'dart:async';
import 'services/clock_service.dart';
import 'models/clock_info.dart';

class TimeClockPage extends StatefulWidget {
  const TimeClockPage({super.key, required this.title, required this.token});

  final String title;
  final String token;

  @override
  State<TimeClockPage> createState() => _TimeClockPageState();
}

class _TimeClockPageState extends State<TimeClockPage> {
  String _currentTime = '';
  String _currentDate = '';
  late Timer _timer;
  bool _isLoading = true;
  ClockInfo? _clockInfo;
  late ClockService _clockService;

  @override
  void initState() {
    super.initState();
    _clockService = ClockService(token: widget.token);
    _updateTimeAndDate();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateTimeAndDate(),
    );
    _fetchClockInfo();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchClockInfo() async {
    try {
      final clockInfo = await _clockService.fetchClockInfo();
      setState(() {
        _clockInfo = clockInfo;
        _isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _updateTimeAndDate() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
      _currentDate =
          '${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)} (${_getWeekdayName(now.weekday)})';
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _getWeekdayName(int weekday) {
    const weekdayNames = ['', '一', '二', '三', '四', '五', '六', '日'];
    return weekdayNames[weekday];
  }

  Future<void> _clockIn() async {
    try {
      await _clockService.clockIn();
      await _fetchClockInfo(); // 重新取得打卡狀態
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('上班打卡成功！')));
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _clockOut() async {
    try {
      await _clockService.clockOut();
      await _fetchClockInfo(); // 重新取得打卡狀態
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('下班打卡成功！')));
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_currentDate, style: const TextStyle(fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Color(0xFFFF5E4F),
                ),
                const SizedBox(width: 4),
                Text(
                  _currentTime,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 50),
            if (_clockInfo != null && !_clockInfo!.isPunchButtonEnabled)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '目前無法打卡',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildClockButton(
                      label: '上班',
                      onPressed:
                          (_clockInfo?.isPunchButtonEnabled == true &&
                                  _clockInfo?.clockIn?.time == null)
                              ? _clockIn
                              : null,
                      recordedTime: _clockInfo?.clockIn?.time ?? '',
                      timeLabel: '上班時間',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildClockButton(
                      label: '下班',
                      onPressed:
                          (_clockInfo?.isPunchButtonEnabled == true &&
                                  _clockInfo?.clockOut?.time == null)
                              ? _clockOut
                              : null,
                      recordedTime: _clockInfo?.clockOut?.time ?? '',
                      timeLabel: '下班時間',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockButton({
    required String label,
    required VoidCallback? onPressed,
    required String recordedTime,
    required String timeLabel,
  }) {
    final Color buttonColor = const Color(0xFF0072F0);
    final bool isDisabled = onPressed == null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? Colors.grey : buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          height: 30,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child:
                recordedTime.isNotEmpty
                    ? Text('$timeLabel: $recordedTime')
                    : null,
          ),
        ),
      ],
    );
  }
}
