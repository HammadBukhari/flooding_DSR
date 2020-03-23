import "dart:convert";

import 'Edge.dart';

class Node {
  String nid;
  List<Edge> edges;
  int x;
  int y;
  Node({
    this.nid,
    this.edges,
    this.x,
    this.y,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'nid': nid,
  //     'edges': List<dynamic>.from(edges.map((x) => x.toMap())),
  //     'x': x,
  //     'y': y,
  //   };
  // }

  // static Node fromMap(Map<String, dynamic> map) {
  //   if (map == null) return null;

  //   return Node(
  //     nid: map['nid'],
  //     edges: List<Edge>.from(map['edges']?.map((x) => Edge.fromMap(x))),
  //     x: map['x'],
  //     y: map['y'],
  //   );
  // }

  // String toJson() => json.encode(toMap());

  // static Node fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Node(nid: $nid, edges: $edges, x: $x, y: $y)';
  }
}
