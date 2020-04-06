import "dart:convert";

import 'Edge.dart';

class GlobalEdge extends Edge {
  String ip;
  String port;

  GlobalEdge(String nid, String ip, String port) : super(nid) {
    this.ip = ip;
    this.port = port;
  }

  Map<String, dynamic> toMap() {
    return {
      "nid": nid,
      'ip': ip,
      'port': port,
    };
  }

  static GlobalEdge fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return GlobalEdge(
      map['nid'],
      map['ip'],
      map['port'],
    );
  }

  String toJson() => json.encode(toMap());

  static GlobalEdge fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'GlobalEdge(nid: $nid ip: $ip, port: $port)';
}
