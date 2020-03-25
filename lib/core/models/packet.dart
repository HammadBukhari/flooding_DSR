import 'package:uuid/uuid.dart';

class Packet {
  String uid = Uuid().v1().toString();
  String message;
  Packet({
    this.message,
    this.uid
  });

  @override
  String toString() => 'Packet(message: $message)';
}
