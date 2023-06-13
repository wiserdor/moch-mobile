class MochNotification {
  final String message;
  final DateTime timestamp;
  bool seen;

  MochNotification(
      {required this.message, required this.timestamp, this.seen = false});
}
