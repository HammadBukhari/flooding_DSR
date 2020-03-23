import "dart:convert";
import 'Edge.dart';

class LocalEdge extends Edge {
  LocalEdge(String nid) : super(nid);
  String toString() => "$nid";
}
