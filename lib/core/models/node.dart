import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';

import 'package:iot_assignment_1/core/enum/node_state.dart';
import 'package:iot_assignment_1/core/models/GlobalEdge.dart';
import 'package:iot_assignment_1/core/models/LocalEdge.dart';
import 'package:iot_assignment_1/core/models/packet.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import 'package:iot_assignment_1/locator.dart';
import 'package:chance/chance.dart';

import 'Edge.dart';

class Node {
  Function lanConnection = getIt<NodeProvider>().searchNodeByNid;
  Function wanConnection = getIt<NodeProvider>().broadcastOverNetwork;
  NodeProvider provider = getIt<NodeProvider>();
  final streamController = StreamController<Either<NodeState, Packet>>();
  Stream<Either<NodeState, Packet>> get nodeStatusStream {
    return streamController.stream;
  }

  String deviceIdentifier;
  String nid;
  List<Edge> edges;
  int x;
  int y;
  Node({
    this.deviceIdentifier,
    this.nid,
    this.edges,
    this.x,
    this.y,
  }) {
    initNode();
  }
// randomly decide to drop the packet to simulate packet drop
  bool shouldForwardPacket() {
    if (Random().nextInt(101) <= provider.packetDropProbability) {
      streamController.sink.add(Left(NodeState.packetDrop));
      Future.delayed(Duration(seconds: 2))
          .then((value) => streamController.sink.add(Left(NodeState.idle)));
      return false;
    }
    return true;
  }

  int calcualteBandwidthRequired(Packet packet) {
    return packet.message.length;
  }

  Future<int> processPacket(Packet packet) async {
    int payload = calcualteBandwidthRequired(packet);
    await Future.delayed(Duration(milliseconds: 50 * payload));
    print(
        "${this.nid}, ${packet.uid}, ${packet.sourceNid}, ${packet.destinationNid}, ${packet.message}, $payload");

    return payload;
  }

  void initNode() {
    List<Edge> removedEdge = [];
    Timer.periodic(
        Duration(seconds: 3),
        (timer) {
      // if (Chance().boolean(likelihood: provider.mobilityProbability)) {
      if (Chance().boolean(likelihood: provider.mobilityProbability)) {
        // drop connection
        if (edges.length > 1) {
          removedEdge.add(edges.removeAt(Random().nextInt(edges.length)));
          streamController.sink.add(Left(NodeState.connectionLoss));
        }
      } else {
        //restablish connection
        if (removedEdge.length > 0) {
          edges.add(removedEdge.removeAt(Random().nextInt(removedEdge.length)));
          streamController.sink.add(Left(NodeState.connectionEstablished));
        }
      }
      // }
    });
  }

  void addGlobalEdge(GlobalEdge edge) {
    streamController.sink.add(Left(NodeState.newEdgeAdded));
    edges.add(edge);
  }

  bool hasLeftEdge() {
    for (final edge in edges) {
      if (edge.nid == "$deviceIdentifier$y${x - 1}") return true;
    }
    return false;
  }

  bool hasRightEdge() {
    for (final edge in edges) {
      if (edge.nid == "$deviceIdentifier$y${x + 1}") return true;
    }
    return false;
  }

  bool hasUpEdge() {
    for (final edge in edges) {
      if (edge.nid == "$deviceIdentifier${y - 1}$x") return true;
    }
    return false;
  }

  bool hasDownEdge() {
    for (final edge in edges) {
      if (edge.nid == "$deviceIdentifier${y + 1}$x") return true;
    }
    return false;
  }

  List<Packet> alreadyBroadcasted = [];
  @override
  String toString() {
    return 'Node(nid: $nid, edges: $edges, x: $x, y: $y)';
  }

  Future<void> broadcast(Packet packet) async {
    if (!alreadyBroadcasted.contains(packet) && shouldForwardPacket()) {
      streamController.sink.add(Left(NodeState.busy));
      await processPacket(packet);
      alreadyBroadcasted.add(packet);

      if (packet.destinationNid == this.nid) {
        streamController.sink.add(Right(packet));
        print("dest arrived");
        return;
      }
      for (final edge in edges) {
        if (edge is LocalEdge) {
          getIt<NodeProvider>().searchNodeByNid(edge.nid).broadcast(packet);
        } else if (edge is GlobalEdge) {
          print("sending to network");
          getIt<NodeProvider>().broadcastOverNetwork(this, edge, packet);
        }
      }
      streamController.sink.add(Left(NodeState.idle));
    }
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Node && o.nid == nid;
  }

  @override
  int get hashCode {
    return nid.hashCode ^ edges.hashCode ^ x.hashCode ^ y.hashCode;
  }
}
