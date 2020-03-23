import "dart:convert";
import 'Edge.dart';

class GlobalEdge extends Edge {
  String ip;
  String port;

  GlobalEdge(String nid) : super(nid);
}
