import 'package:dartz/dartz.dart';
import 'package:iot_assignment_1/core/enum/node_state.dart';
import 'package:iot_assignment_1/core/models/Edge.dart';
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:iot_assignment_1/core/models/packet.dart';

class Flooding {
  void initFlooding(
      List<Node> nodes, String source, String destination, Packet msg) {
    Node sourceNode = searchNodeByNid(nodes, source);
    Node destNode = searchNodeByNid(nodes, destination);
    // flood(nodes, sourceNode, destNode, msg);
    sourceNode.broadcast(destNode, msg);
  }

  // void flood(List<Node> nodes, Node source, Node dest, Packet msg) {
  //   source.streamController.sink.add(Left(NodeState.busy));
  //   if (source.nid == dest.nid) {
  //     source.streamController.sink.add(Right(msg));
  //   } else {
  //     for (final edge in source.edges) {
  //       Node nodeToBroadcast = searchNodeByNid(nodes, edge.nid);
  //       if (!source.receivedFrom.contains(nodeToBroadcast)) {
  //         nodeToBroadcast.receivedFrom.add(source);
  //         print("broadcasting to $nodeToBroadcast\n");
  //         source.streamController.sink.add(Left(NodeState.idle));
  //         flood(nodes, nodeToBroadcast, dest, msg);
  //       }
  //     }
  //   }
  // }

  Node searchNodeByNid(List<Node> nodes, String nid) {
    for (final node in nodes) {
      if (node.nid == nid) return node;
    }
    return null;
  }
}
