import 'dart:math';

class Formatters {
  /// Formats ticks into "HHh MMm" or "MM min" or "M min"
  static String formatDuration(int? ticks) {
    if (ticks == null) return '';
    final duration = Duration(microseconds: ticks ~/ 10);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes} min';
  }

  /// Formats duration for the video player slider (HH:mm:ss or mm:ss)
  static String formatTime(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  /// Formats bytes into "MB", "GB", etc.
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Formats network speed
  static String formatSpeed(double bytesPerSec) {
    if (bytesPerSec <= 0) return '';
    const suffixes = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var i = (log(bytesPerSec) / log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytesPerSec / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Formats remaining time (e.g. "45m left", "1h 20m left")
  static String formatTimeRemaining(int ticks) {
    if (ticks <= 0) return '';
    final duration = Duration(microseconds: ticks ~/ 10);
    if (duration.inMinutes < 1) return '< 1m left';

    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m left';
    }
    return '${duration.inMinutes}m left';
  }
}
