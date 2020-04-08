
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:iot_assignment_1/core/models/packet.dart';
import 'package:uuid/uuid.dart';

class Flooding {
  void initFlooding(
      List<Node> nodes, String source, String destination, String msg) {
    Node sourceNode = searchNodeByNid(nodes, source);
    final packet = Packet(Uuid().v1().toString(), msg,source, destination);
    // flood(nodes, sourceNode, destNode, msg);
    sourceNode.broadcast(packet);
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
