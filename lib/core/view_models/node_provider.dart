import 'package:iot_assignment_1/core/models/Edge.dart';
import 'package:iot_assignment_1/core/models/GlobalEdge.dart';
import 'package:iot_assignment_1/core/models/LocalEdge.dart';
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:iot_assignment_1/core/models/packet.dart';
import 'package:iot_assignment_1/core/services/flooding.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

import 'package:iot_assignment_1/locator.dart';

class NodeProvider extends ChangeNotifier {
  List<Node> nodes = [];
  String deviceIdentifier = "A";
  int _rowCount = 10;
  int _columnCount = 4;
  Random random = Random();
  // Probablitiy of node movement from 0 to 1.0 inclusive
  double _mobilityProbability = 0.0;

  // Probablility of packet drop from 0 to 1.0 inclusive
  double _packetDropProbability = 0.0;
  //
  void setDeviceIdentifier(String deviceIdentifier) {
    this.deviceIdentifier = deviceIdentifier;
  }

  void setMobilityProbability(double mobilityProbability) {
    this._mobilityProbability = mobilityProbability;
  }

  void setPacketDropProbability(double packetDropProbability) {
    this._packetDropProbability = packetDropProbability;
  }

  void flood(String source, String dest, Packet msg) {
    var flood = Flooding(); //getIt<Flooding>();
    flood.initFlooding(nodes, source, dest, msg);
  }

  bool makeConnection() {
    return !(random.nextInt(10) == 1);
  }

  // device identifer must must set before calling initNodes
  void initNodes() {
    for (int y = 0; y < _rowCount; y++) {
      for (int x = 0; x < _columnCount; x++) {
        // if x = 0  no left edge
        // if y = 0 no up edge
        // if y = _rowCount no down edge
        // if x = _columnCount no right edge
        List<Edge> edges = [];
        if (x != 0) {
          if (makeConnection()) {
            edges.add(LocalEdge(
                "$deviceIdentifier$y${x - 1}")); // Ayx A02 -> left A01
          }
        }
        if (y != 0) {
          if (makeConnection()) {
            edges.add(LocalEdge(
                "$deviceIdentifier${y - 1}$x")); // Ayx A02 -> left A01
          }
        }
        if (x + 1 != _columnCount) {
          if (makeConnection()) {
            edges.add(LocalEdge(
                "$deviceIdentifier$y${x + 1}")); // Ayx A02 -> left A01
          }
        }
        if (y + 1 != _rowCount) {
          if (makeConnection()) {
            edges.add(LocalEdge(
                "$deviceIdentifier${y + 1}$x")); // Ayx A02 -> left A01
          }
        }

        nodes.add(Node(deviceIdentifier : deviceIdentifier ,x: x, y: y, nid: "$deviceIdentifier$y$x", edges: edges));
      }
    }
  }

  Node searchNodeByNid(String nid) {
    for (final node in nodes) {
      if (node.nid == nid) return node;
    }
    return null;
  }
}
