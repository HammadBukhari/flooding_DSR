import 'dart:convert';
import 'dart:ffi';

import 'package:iot_assignment_1/core/enum/NetworkMessageType.dart';
import 'package:iot_assignment_1/core/models/ConnectionRequest.dart';
import 'package:iot_assignment_1/core/models/DSRPacket.dart';
import 'package:iot_assignment_1/core/models/GlobalEdge.dart';
import 'package:iot_assignment_1/core/models/packet.dart';

class NetworkMessage {
  NetworkMessageType type;
  String senderUid;
  String receiverUid;
  dynamic packet;
  NetworkMessage({this.type, this.packet, this.senderUid, this.receiverUid});

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'packet': packet.toMap(),
    };
  }

  static NetworkMessage fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    final type = NetworkMessageType.values[map['type']];
    
    dynamic packet;
    if (type == NetworkMessageType.connectionRequest) {
      packet = ConnectionRequest.fromMap(map['packet']);
    } else if (type == NetworkMessageType.flood) {
      packet = Packet.fromMap(map['packet']);
    } else if (type == NetworkMessageType.DSR) {
      packet = DSRPacket.fromMap(map['packet']);
    }
    return NetworkMessage(
      type: type,
      packet: packet,
      senderUid: map['senderUid'],
      receiverUid: map['receiverUid'],
    );
  }

  String toJson() => json.encode(toMap());

  static NetworkMessage fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'NetworkMessage(packet: $packet)';
}
