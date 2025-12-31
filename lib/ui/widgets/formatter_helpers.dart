import 'package:intl/intl.dart';

// DURATION FORMATTER
// Handle HH:MM:SS or MM:SS formats
String formatDurationNumeric(dynamic raw) {
  int totalSeconds = 0;
  if (raw is num) {
    totalSeconds = raw.toInt();
  } else if (raw is String) {
    totalSeconds = int.tryParse(raw) ?? 0;
  }

  if (totalSeconds == 0) return '0:00';

  final duration = Duration(seconds: totalSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final minutesStr = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
  final secondsStr = seconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$secondsStr';
  }
  return '$minutesStr:$secondsStr';
}

// TIME FORMATTER
String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

  // If the audio is 1 hour or longer: 1:05:03
  if (duration.inHours > 0) {
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }
  // Otherwise: 5:03 (No leading zero on minutes if less than 10)
  return "${duration.inMinutes.remainder(60)}:$twoDigitSeconds";
}

// DATE FORMATTER
String formatDateTime(DateTime dateTime) {
  // final DateFormat formatter = DateFormat('yyyy-MM-dd');
  // ANOTHER FORMAT EXAMPLE:
  // final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
  final DateFormat formatter = DateFormat('MMM dd, yyyy');
  // ANOTHER FORMAT EXAMPLE:
  // final DateFormat formatter = DateFormat.yMMMMd().add_jm();
  return formatter.format(dateTime);
}
