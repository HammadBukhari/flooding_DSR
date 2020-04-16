import 'dart:convert';

import 'package:iot_assignment_1/core/enum/DSR_packet_type.dart';
import 'package:iot_assignment_1/core/models/packet.dart';

class DSRPacket extends Packet {
  List<String> headerNids = [];

  DSRPacketType messageType;

  DSRPacket(String uid, String message, String sourceNid, String destinationNid,
      {this.headerNids, this.messageType})
      : super(uid, message, sourceNid, destinationNid) {
    if (headerNids == null) headerNids = [];
  }

  DSRPacket.copyFrom(DSRPacket p)
      : super(p.uid, p.message, p.sourceNid, p.destinationNid) {
    headerNids = [];
    messageType = p.messageType;
    for (final edge in p.headerNids) {
      headerNids.add(edge);
    }
    this.message = p.message;
    this.uid = p.uid;
  }

  @override
  bool operator ==(Object o) {
    
    return o is DSRPacket && o.uid == uid && o.messageType == messageType && o.message == message;
  }

  @override
  int get hashCode {
    return headerNids.hashCode ^ message.hashCode ^ uid.hashCode;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'message': message,
      'destinationNid': destinationNid,
      'messageType': messageType.index,
      'sourceNid': sourceNid,
      'headerNids': List<dynamic>.from(headerNids.map((x) => x)),
    };
  }

  static DSRPacket fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return DSRPacket(
      map['uid'],
      map['message'],
      map['sourceNid'],
      map['destinationNid'],
      messageType: DSRPacketType.values[map['messageType']],
      headerNids: List<String>.from(map['headerNids']),
    );
  }

  String toJson() => json.encode(toMap());

  static DSRPacket fromJson(String source) => fromMap(json.decode(source));
}
