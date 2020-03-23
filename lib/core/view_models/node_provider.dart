import 'package:iot_assignment_1/core/models/Edge.dart';
import 'package:iot_assignment_1/core/models/GlobalEdge.dart';
import 'package:iot_assignment_1/core/models/LocalEdge.dart';
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

class NodeProvider extends ChangeNotifier {
  List<Node> nodes = [];
  String deviceIdentifier = "A"; // TODO: create device identifier setter
  int rowCount = 10;
  int columnCount = 4;
  Random random = Random();
  // device identifer must must set before calling initNodes
  void initNodes() {
    for (int y = 0; y < rowCount; y++) {
      for (int x = 0; x < columnCount; x++) {
        // if x = 0  no left edge
        // if y = 0 no up edge
        // if y = rowCount no down edge
        // if x = columnCount no right edge
        List<Edge> edges = [];
        if (x != 0) {
          if (random.nextInt(2) == 1) {
            edges.add(LocalEdge(
                "$deviceIdentifier${x - 1}$y")); // Ayx A02 -> left A01
          }
        }
        if (y != 0) {
          if (random.nextInt(2) == 1) {
            edges.add(LocalEdge(
                "$deviceIdentifier$x${y - 1}")); // Ayx A02 -> left A01
          }
        }
        if (x + 1 != columnCount) {
          if (random.nextInt(2) == 1) {
            edges.add(LocalEdge(
                "$deviceIdentifier${x + 1}$y")); // Ayx A02 -> left A01
          }
        }
        if (y + 1 != rowCount) {
          if (random.nextInt(2) == 1) {
            edges.add(LocalEdge(
                "$deviceIdentifier$x${y + 1}")); // Ayx A02 -> left A01
          }
        }

        nodes.add(Node(x: x, y: y, nid: "$deviceIdentifier$x$y", edges: edges));
      }
    }
  }
}
