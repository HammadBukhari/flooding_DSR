import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:iot_assignment_1/core/enum/DSR_packet_type.dart';
import 'package:iot_assignment_1/core/enum/node_state.dart';
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:iot_assignment_1/core/models/packet.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import 'package:uuid/uuid.dart';

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
  @override
  int calcualteBandwidthRequired(Packet packet) {
    return packet.message.length +
        (packet as DSRPacket).headerNids.fold(
            0, (previousValue, element) => previousValue + element.length);
  }

  Future<void> routeReply(DSRPacket packet) async {
    if (!isPacketAlreadyBroadcasted(packet) && shouldForwardPacket()) {
      //print("RREP reached at $this");
      streamController.sink.add(Left(NodeState.routeReply));
      alreadyBroadcasted.add(packet);
      await processPacket(packet);
      addInCache(packet.headerNids);

      if (this.nid == packet.sourceNid) {
        directMessage(packet);
        streamController.sink.add(Left(NodeState.idle));

        return;
      }
      for (final edge in edges) {
        if (edge is LocalEdge) {
          (lanConnection(edge.nid) as DSRNode)?.routeReply(packet);
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

  Future<void> routeError(DSRPacket packet) async {
    if (!isPacketAlreadyBroadcasted(packet) && shouldForwardPacket()) {
      alreadyBroadcasted.add(packet);
      streamController.sink.add(Left(NodeState.routeError));
      await processPacket(packet);
      removeInCache(packet.message);
      if (this.nid == packet.sourceNid) {
        streamController.sink.add(Left(NodeState.routeError));
        // // restarting the whole DSR process
        // packet.messageType = DSRPacketType.RREQ;
        // // new id so nodes do forward it
        // packet.uid = Uuid().v1().toString();

        // routeRequest(DSRPacket.copyFrom(packet));
        return;
      }
      for (final edge in edges) {
        if (edge is LocalEdge) {
          (lanConnection(edge.nid) as DSRNode)?.routeError(packet);
        } else if (edge is GlobalEdge) {
          getIt<NodeProvider>().dsrOverNetwork(this, edge, packet);
        }
      }
      streamController.sink.add(Left(NodeState.idle));
    }
  }

  void removeInCache(String pair) {
    final firstNode = pair.substring(0, 2);
    final secondNode = pair.substring(3, 5);
    // check if [_cache] contains the first node
    for (final cache in _cache) {
      final indexOfFirstNode = cache.indexOf(firstNode);
      if (indexOfFirstNode == -1) continue;

      // if [firstNode] is last item in cache list
      // then no possiblity of pair
      if (cache.last == firstNode) return;
      // if the next element of [firstNode] is [secondNode] then
      // the corrupted cache is found and should be removed
      if (cache[indexOfFirstNode + 1] == secondNode) _cache.remove(cache);
    }
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
    print("${this}'s cache");
    _cache.forEach(print);
    // set a callback to purge this cache
    Future.delayed(Duration(minutes: 60), () {
      _cache.remove(toAdd);
      // purge cache after 60 seconds
      print("purging ${this.nid}'s $toAdd");
    });
  }

  Future<void> directMessage(DSRPacket packet) async {
    streamController.sink.add(Left(NodeState.busy));
      await processPacket(packet);
    addInCache(packet.headerNids);
    if (this.nid == packet.destinationNid) {
      streamController.sink.add(Right(packet));
      print("RRRRRRRRRRRRRRRRRRRRR");
      return;
    }
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
        (lanConnection(edgeToForward.nid) as DSRNode)?.directMessage(packet);
      } else {
        packet.messageType = DSRPacketType.MESG;
        getIt<NodeProvider>().dsrOverNetwork(this, edgeToForward, packet);
      }
    } else {
      // edge is remove sent route error
      packet.messageType = DSRPacketType.RERR;
      // set message to the two pair of which connection
      // is destroyed
      packet.message = "${this.nid}${packet.headerNids.first}";
      routeError(DSRPacket.copyFrom(packet));
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
    if (!isPacketAlreadyBroadcasted(packet) && shouldForwardPacket()) {
      alreadyBroadcasted.add(packet);
      streamController.sink.add(Left(NodeState.busy));
      await processPacket(packet);
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
          (lanConnection(edge.nid) as DSRNode)
              ?.routeRequest(DSRPacket.copyFrom(packet));
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
