import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iot_assignment_1/core/enum/DSR_packet_type.dart';
import 'package:iot_assignment_1/core/enum/NetworkMessageType.dart';
import 'package:iot_assignment_1/core/enum/packet_type.dart';
import 'package:iot_assignment_1/core/models/ConnectionRequest.dart';
import 'package:iot_assignment_1/core/models/DSRNode.dart';
import 'package:iot_assignment_1/core/models/DSRPacket.dart';
import 'package:iot_assignment_1/core/models/Edge.dart';
import 'package:iot_assignment_1/core/models/GlobalEdge.dart';
import 'package:iot_assignment_1/core/models/LocalEdge.dart';
import 'package:iot_assignment_1/core/models/NetworkMessage.dart';
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:iot_assignment_1/core/models/packet.dart';
import 'package:iot_assignment_1/core/services/flooding.dart';
import 'package:uuid/uuid.dart';

class NodeProvider extends ChangeNotifier {
  List<Node> nodes = [];
  String deviceIdentifier = "A";
  int _rowCount = 10;
  int get rowCount => _rowCount;
  int _columnCount = 4;
  int port = 1999;
  final path = "file.txt";
  Random random = Random();

  // Probablitiy of node movement from 0 to 100 inclusive
  double mobilityProbability = 1;

  // Probablility of packet drop from 0 to 100 inclusive
  double packetDropProbability = 1;
  //
  void setDeviceIdentifier(String deviceIdentifier) {
    this.deviceIdentifier = deviceIdentifier;
    initNodes(AlgorithmType.DSR);
  }

  bool setMobilityProbability(String mobilityProbability) {
    try {
      this.mobilityProbability = double.parse(mobilityProbability);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool setPacketDropProbability(String packetDropProbability) {
    try {
      this.packetDropProbability = double.parse(packetDropProbability);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<String> getDeviceLocalIp() {
    return Connectivity().getWifiIP();
  }

  Future<void> sendNewGlobalEdgeOverNetwork(
      Node sourceNode, String destNid, String destIp) async {
    String myIp = await getDeviceLocalIp();
    print(myIp);
    final networkMessage = NetworkMessage(
      type: NetworkMessageType.connectionRequest,
      senderUid: sourceNode.nid,
      receiverUid: destNid,
      packet: ConnectionRequest(
          edge: GlobalEdge(sourceNode.nid, myIp, port.toString())),
    );
    HttpClientRequest request = await HttpClient().post(destIp, port, path)
      ..headers.contentType = ContentType.json
      ..write(networkMessage.toJson());
    HttpClientResponse response = await request.close();
    await utf8.decoder.bind(response).forEach((element) {
      Fluttertoast.showToast(msg: element);
      print(element);
    });

    // adding globalEdge on this client
    searchNodeByNid(sourceNode.nid)
        .addGlobalEdge(GlobalEdge(destNid, destIp, port.toString()));
  }

  Future<void> initNetwork() async {
    var server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    await for (var req in server) {
      ContentType contentType = req.headers.contentType;
      HttpResponse response = req.response;
      if (req.method == 'POST' && contentType?.mimeType == 'application/json') {
        try {
          String content = await utf8.decoder.bind(req).join();
          // var data = jsonDecode(content) as Map;

          NetworkMessage networkMessage = NetworkMessage.fromJson(content);
          if (networkMessage.type == NetworkMessageType.connectionRequest) {
            ConnectionRequest connectionRequest = networkMessage.packet;
            Fluttertoast.showToast(msg: networkMessage.packet.toString());
            searchNodeByNid(networkMessage.receiverUid)
                .addGlobalEdge(connectionRequest.edge);
            req.response
              ..statusCode = HttpStatus.ok
              ..write('Edge added');
          } else if (networkMessage.type == NetworkMessageType.flood) {
            Packet packet = networkMessage.packet;
            searchNodeByNid(networkMessage.receiverUid).broadcast(packet);
            req.response
              ..statusCode = HttpStatus.ok
              ..write('broadcasted over network');
          } else if (networkMessage.type == NetworkMessageType.DSR) {
            DSRPacket packet = networkMessage.packet;
            if (packet.messageType == DSRPacketType.RREP) {
              (searchNodeByNid(networkMessage.receiverUid) as DSRNode)
                  .routeReply(packet);
            } else if (packet.messageType == DSRPacketType.RREQ) {
              (searchNodeByNid(networkMessage.receiverUid) as DSRNode)
                  .routeRequest(packet);
            } else if (packet.messageType == DSRPacketType.MESG) {
              (searchNodeByNid(networkMessage.receiverUid) as DSRNode)
                  .directMessage(packet);
            } else if (packet.messageType == DSRPacketType.RERR) {
              (searchNodeByNid(networkMessage.receiverUid) as DSRNode)
                  .routeError(packet);
            }
          }
        } catch (e) {
          response
            ..statusCode = HttpStatus.internalServerError
            ..write('Exception: $e.');
        }
      } else {
        response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Unsupported request: ${req.method}.');
      }
      await response.close();
    }
  }

  void flood(String source, String dest, String msg) {
    var flood = Flooding(); //getIt<Flooding>();
    flood.initFlooding(nodes, source, dest, msg);
  }

  void makeDSRRreq(String source, String dest, String msg) {
    final sourceNode = searchNodeByNid(source) as DSRNode;
    final packet = DSRPacket(Uuid().v1().toString(), msg, source, dest);
    sourceNode.routeRequest(packet);
  }

  bool makeConnection() {
    return !(random.nextInt(100-mobilityProbability.toInt()) == 1);
  }

  // device identifer must must set before calling initNodes
  void initNodes(AlgorithmType type) {
    nodes.clear();
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
        if (type == AlgorithmType.Flooding)
          nodes.add(Node(
              deviceIdentifier: deviceIdentifier,
              x: x,
              y: y,
              nid: "$deviceIdentifier$y$x",
              edges: edges));
        else
          nodes.add(
              DSRNode("$deviceIdentifier$y$x", edges, x, y, deviceIdentifier));
      }
    }
  }

  Future<void> broadcastOverNetwork(
      Node sender, GlobalEdge edge, Packet packet) async {
    final networkMessage = NetworkMessage(
      type: NetworkMessageType.flood,
      receiverUid: edge.nid,
      senderUid: sender.nid,
      packet: packet,
    );
    HttpClientRequest request = await HttpClient().post(edge.ip, port, path)
      ..headers.contentType = ContentType.json
      ..write(networkMessage.toJson());
    HttpClientResponse response = await request.close();
    await utf8.decoder.bind(response /*5*/).forEach((element) {
      Fluttertoast.showToast(msg: element);
      print(element);
    });
  }

  Future<void> dsrOverNetwork(
      Node sender, GlobalEdge edge, Packet packet) async {
    final networkMessage = NetworkMessage(
      type: NetworkMessageType.DSR,
      receiverUid: edge.nid,
      senderUid: sender.nid,
      packet: packet,
    );
    HttpClientRequest request = await HttpClient().post(edge.ip, port, path)
      ..headers.contentType = ContentType.json
      ..write(networkMessage.toJson());
    HttpClientResponse response = await request.close();
    await utf8.decoder.bind(response /*5*/).forEach((element) {
      Fluttertoast.showToast(msg: element);
      print(element);
    });
  }

  Node searchNodeByNid(String nid) {
    for (final node in nodes) {
      if (node.nid == nid) return node;
    }
    return null;
  }
}
