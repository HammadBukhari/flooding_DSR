import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:iot_assignment_1/core/enum/node_state.dart';
import 'package:iot_assignment_1/core/models/packet.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import 'package:iot_assignment_1/locator.dart';

import 'Edge.dart';

class Node {
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
  });
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
      if (edge.nid == "$deviceIdentifier${y-1}$x") return true;
    }
    return false;
  }

  bool hasDownEdge() {
    for (final edge in edges) {
      if (edge.nid == "$deviceIdentifier${y+1}$x") return true;
    }
    return false;
  }

  List<Packet> alreadyBroadcasted = [];
  @override
  String toString() {
    return 'Node(nid: $nid, edges: $edges, x: $x, y: $y)';
  }

  Future<void> broadcast(Node destination, Packet packet) async {
    print("${this}\n");
    if (!alreadyBroadcasted.contains(packet)) {
      streamController.sink.add(Left(NodeState.busy));
      await Future.delayed(Duration(milliseconds: 500));
      alreadyBroadcasted.add(packet);

      if (this == destination) {
        streamController.sink.add(Right(packet));
        print("dest arrived");
        return;
      }
      for (final edge in edges) {
        getIt<NodeProvider>()
            .searchNodeByNid(edge.nid)
            .broadcast(destination, packet);
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
