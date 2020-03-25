import 'package:iot_assignment_1/core/models/node.dart';

import 'Edge.dart';

class DSRNode extends Node {
  DSRNode(String nid, List<Edge> edges, int x, int y)
      : super(nid: nid, edges: edges, x: x, y: y);
  List<List<Edge>> _cache;
}
