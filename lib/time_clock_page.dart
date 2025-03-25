import 'package:flutter/material.dart';
import 'dart:async';

class TimeClockPage extends StatefulWidget {
  const TimeClockPage({super.key, required this.title});

  final String title;

  @override
  State<TimeClockPage> createState() => _TimeClockPageState();
}

class _TimeClockPageState extends State<TimeClockPage> {
  String _currentTime = '';
  String _currentDate = '';
  String _clockInTime = '';
  String _clockOutTime = '';
  late Timer _timer;
  
  @override
  void initState() {
    super.initState();
    _updateTimeAndDate();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTimeAndDate());
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  void _updateTimeAndDate() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
      _currentDate = '${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)} (${_getWeekdayName(now.weekday)})';
    });
  }
  
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  
  String _getWeekdayName(int weekday) {
    const weekdayNames = ['', '一', '二', '三', '四', '五', '六', '日'];
    return weekdayNames[weekday];
  }
  
  void _clockIn() {
    setState(() {
      _clockInTime = _currentTime;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('上班打卡成功！')),
    );
  }
  
  void _clockOut() {
    setState(() {
      _clockOutTime = _currentTime;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('下班打卡成功！')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              _currentDate,
              style: const TextStyle(fontSize: 20),
            ),
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
                  style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildClockButton(
                      label: '上班',
                      onPressed: _clockInTime.isEmpty ? _clockIn : null,
                      recordedTime: _clockInTime,
                      timeLabel: '上班時間',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildClockButton(
                      label: '下班',
                      onPressed: _clockOutTime.isEmpty ? _clockOut : null,
                      recordedTime: _clockOutTime,
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
            child: recordedTime.isNotEmpty
                ? Text('$timeLabel: $recordedTime')
                : null,
          ),
        ),
      ],
    );
  }
}
