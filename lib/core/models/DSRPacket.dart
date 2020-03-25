import 'package:iot_assignment_1/core/models/packet.dart';

import 'Edge.dart';

class DSRPacket extends Packet {
  List<Edge> header;
  DSRPacket(
    String message, {
    this.header,
  }) : super(message: message);
}
                         