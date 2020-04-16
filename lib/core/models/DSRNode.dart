import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:iot_assignment_1/core/enum/DSR_packet_type.dart';
import 'package:iot_assignment_1/core/enum/node_state.dart';
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';

import '../../locator.dart';
import 'DSRPacket.dart';
import 'Edge.dart';
import 'GlobalEdge.dart';
import 'LocalEdge.dart';

class DSRNode extends Node {
  DSRNode(String nid, List<Edge> edges, int x, int y, String deviceIdentifer)
      : super(
            nid: nid,
            edges: edges,
            x: x,
            y: y,
            deviceIdentifier: deviceIdentifer);
  List<List<String>> _cache = [];
  Future<void> routeReply(DSRPacket packet) async {
    if (!isPacketAlreadyBroadcasted(packet)) {
      //print("RREP reached at $this");
      streamController.sink.add(Left(NodeState.routeReply));
      alreadyBroadcasted.add(packet);
      await Future.delayed(Duration(milliseconds: 750));
      addInCache(packet.headerNids);

      if (this.nid == packet.sourceNid) {
        directMessage(packet);
        streamController.sink.add(Left(NodeState.idle));

        return;
      }
      for (final edge in edges) {
        if (edge is LocalEdge) {
          final nodeToSend =
              getIt<NodeProvider>().searchNodeByNid(edge.nid) as DSRNode;
          nodeToSend.routeReply(packet);
        } else if (edge is GlobalEdge) {
          packet.messageType = DSRPacketType.RREP;
          getIt<NodeProvider>().dsrOverNetwork(this, edge, packet);
        }
      }
    }
    streamController.sink.add(Left(NodeState.idle));
  }

  List<String> findNodeInCache(String destNid) {
    for (final cacheItem in _cache) {
      for (int i = 1; i < cacheItem.length; i++) {
        if (cacheItem[i] == destNid) {
          return cacheItem.sublist(0, i + 1);
        }
      }
    }
    return null;
  }

  void addInCache(List<String> toAdd) {
    //   // if path is null or doesnt contain at least one source and destination
    // then no need to add it
    if (toAdd.isEmpty && toAdd.length < 2) return;

    // search if this header contain our node
    bool isCachingNeeded = false;
    for (int i = 0; i < toAdd.length; i++) {
      if (toAdd[i] == this.nid) {
        isCachingNeeded = true;
        toAdd = toAdd.sublist(i, toAdd.length);
        if (toAdd.length < 2) return; // when [this] is destintion
        break;
      }
    }

    if (!isCachingNeeded) return;

    for (final cacheItem in _cache) {
      if (cacheItem.first == toAdd.first && cacheItem.last == toAdd.last)
        return;
    }
    // finally add it to cache list
    _cache.add(toAdd);
    print("${this.nid} added $toAdd");
    // set a callback to purge this cache
    Future.delayed(Duration(seconds: 60), () {
      _cache.remove(toAdd);
      // purge cache after 60 seconds
      print("purging ${this.nid}'s $toAdd");
    });
  }

  Future<void> directMessage(DSRPacket packet) async {
    streamController.sink.add(Left(NodeState.busy));
    await Future.delayed(Duration(milliseconds: 750));
    addInCache(packet.headerNids);
    if (this.nid == packet.destinationNid) {
      streamController.sink.add(Right(packet));
      print("RRRRRRRRRRRRRRRRRRRRR");
      return;
    }
    // if (edges.contains(packet.headerNids[1])) {
    //   packet.headerNids.removeAt(0);
    //   final nextEdge = packet.headerNids[0];
    //   if (nextEdge is LocalEdge) {
    //     final nodeToSend = getIt<NodeProvider>()
    //         .searchNodeByNid(packet.headerNids[0].nid) as DSRNode;
    //     nodeToSend.directMessage(packet);
    //   } else {
    //     packet.messageType = DSRPacketType.MESG;
    //     getIt<NodeProvider>().dsrOverNetwork(this, nextEdge, packet);
    //   }
    packet.headerNids.removeAt(0);
    Edge edgeToForward;
    for (final edge in this.edges) {
      if (edge.nid == packet.headerNids.first) {
        edgeToForward = edge;
        break;
      }
    }
    if (edgeToForward != null) {
      if (edgeToForward is LocalEdge) {
        final nodeToSend =
            getIt<NodeProvider>().searchNodeByNid(edgeToForward.nid) as DSRNode;
        nodeToSend.directMessage(packet);
      } else {
        packet.messageType = DSRPacketType.MESG;
        getIt<NodeProvider>().dsrOverNetwork(this, edgeToForward, packet);
      }
    } else {
      // edge is remove sent route error
    }
    streamController.sink.add(Left(NodeState.idle));
  }

  bool isPacketAlreadyBroadcasted(DSRPacket packet) {
    for (var p in alreadyBroadcasted) {
      if (p.uid == packet.uid) return true;
    }
    return false;
  }

  Future<void> routeRequest(DSRPacket packet) async {
    if (!isPacketAlreadyBroadcasted(packet)) {
      alreadyBroadcasted.add(packet);
      streamController.sink.add(Left(NodeState.busy));
      await Future.delayed(Duration(milliseconds: 750));
      if (this.nid == packet.destinationNid) {
        packet.headerNids.add(nid);
        routeReply(DSRPacket(
          "${packet.uid}RREP",
          packet.message,
          packet.sourceNid,
          packet.destinationNid,
          headerNids: packet.headerNids,
        ));
        streamController.sink.add(Left(NodeState.idle));
        return;
      }
      // try in cache
      final cacheTryList = findNodeInCache(packet.destinationNid);
      if (cacheTryList != null) {
        packet.headerNids.addAll(cacheTryList);
        final replayPacket = DSRPacket(packet.uid, packet.message,
            packet.sourceNid, packet.destinationNid);

        replayPacket.uid = "${packet.uid}RREP";
        replayPacket.headerNids = packet.headerNids;
        routeReply(replayPacket);
        streamController.sink.add(Left(NodeState.idle));
        return;
      }
      // add the edge in header
      packet.headerNids.add(nid);
      for (final edge in edges) {
        if (edge is LocalEdge) {
          final nodeToSend =
              getIt<NodeProvider>().searchNodeByNid(edge.nid) as DSRNode;
          nodeToSend.routeRequest(DSRPacket.copyFrom(packet));
        } else if (edge is GlobalEdge) {
          packet.messageType = DSRPacketType.RREQ;
          getIt<NodeProvider>()
              .dsrOverNetwork(this, edge, DSRPacket.copyFrom(packet));
        }
      }
      streamController.sink.add(Left(NodeState.idle));
    }
  }

  startDSR(Node source, Node destination, DSRPacket packet) {}
}
