import 'dart:convert';

import 'package:iot_assignment_1/core/models/GlobalEdge.dart';

class ConnectionRequest {
  GlobalEdge edge; // sender edge info 
  ConnectionRequest({
    this.edge,
  });

  

  Map<String, dynamic> toMap() {
    return {
      'edge': edge.toMap(),
    };
  }

  static ConnectionRequest fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return ConnectionRequest(
      edge: GlobalEdge.fromMap(map['edge']),
    );
  }

  String toJson() => json.encode(toMap());

  static ConnectionRequest fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'ConnectionRequest(edge: $edge)';
}
