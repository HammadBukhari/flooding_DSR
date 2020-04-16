import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iot_assignment_1/core/models/DSRPacket.dart';
import 'package:iot_assignment_1/locator.dart';
import 'package:iot_assignment_1/core/enum/packet_type.dart';
import 'package:uuid/uuid.dart';

import 'core/enum/node_state.dart';
import 'core/models/packet.dart';
import 'core/view_models/node_provider.dart'; // connectivity

final _formKey = GlobalKey<FormState>();

void main() {
  setup();
  WidgetsFlutterBinding.ensureInitialized();
  final deviceId = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"];
  final provider = getIt<NodeProvider>();
  provider.setDeviceIdentifier(deviceId[Random().nextInt(deviceId.length)]);
  provider.initNodes(AlgorithmType.DSR);
  provider.initNetwork();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Nodes',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      //new
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final provider = getIt<NodeProvider>();

  Widget buildNodesGrid(BuildContext context) {
    return GridView.builder(
      itemCount: provider.nodes.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (BuildContext context, int index) {
        return StreamBuilder<Either<NodeState, Packet>>(
            stream: provider.nodes[index].nodeStatusStream,
            builder: (context, snapshot) {
              var color = Colors.white;
              if (snapshot.hasData) {
                snapshot.data.fold((l) {
                  if (l == NodeState.busy) {
                    color = Colors.red;
                  } else if (l == NodeState.routeError) {
                    color = Colors.pink;
                  } else if (l == NodeState.routeReply) {
                    color = Colors.yellow;
                  } else if (l == NodeState.packetDrop) {
                    color = Colors.purple;
                  }
                }, (r) {
                  color = Colors.green;
                  print(r.message);
                });
              }
              return Card(
                color: color,
                child: new InkWell(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: provider.nodes[index].edges.fold(
                            "",
                            (previousValue, element) =>
                                "$previousValue \n ${element.toString()}"));
                  },
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    padding: const EdgeInsets.all(8),
                    child: Builder(builder: (BuildContext context) {
                      var stackWidgets = <Widget>[];
                      stackWidgets.add(
                        Align(
                          alignment: Alignment.center,
                          child: new Text(
                            provider.nodes[index].nid,
                            style: TextStyle(fontSize: 22.0),
                          ),
                        ),
                      );
                      if (provider.nodes[index].hasLeftEdge())
                        stackWidgets.add(
                          Align(
                            alignment: Alignment.centerLeft,
                            child: buildVerticalNode(context),
                          ),
                        );
                      if (provider.nodes[index].hasRightEdge())
                        stackWidgets.add(
                          Align(
                            alignment: Alignment.centerRight,
                            child: buildVerticalNode(context),
                          ),
                        );
                      if (provider.nodes[index].hasUpEdge())
                        stackWidgets.add(
                          Align(
                            alignment: Alignment.topCenter,
                            child: buildHorizontalNode(context),
                          ),
                        );
                      if (provider.nodes[index].hasDownEdge())
                        stackWidgets.add(
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: buildHorizontalNode(context),
                          ),
                        );

                      return Stack(children: stackWidgets);
                    }),
                    alignment: Alignment(0.0, 0.0),
                  ),
                ),
              );
            });
      },
    );
  }

  Widget buildHorizontalNode(BuildContext context) {
    return Container(
      color: Colors.lightGreen,
      height: 20,
      width: 5,
    );
  }

  Widget buildVerticalNode(BuildContext context) {
    return Container(
      color: Colors.lightGreen,
      height: 5,
      width: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // provider.makeDSRRreq("E03", "A62", "Heello");
          // provider.sendNewGlobalEdgeOverNetwork(
          // provider.nodes[0], "E00", "192.168.10.4");
          provider.makeDSRRreq("A01", "A31", "msg");
          // provider.flood("I00", "I62", "Hello");
        },
      ),
      appBar: AppBar(
        title: FutureBuilder(
          future: provider.getDeviceLocalIp(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData)
              return Text(snapshot.data.toString());
            else
              return CircularProgressIndicator();
          },
        ),
      ),
      body: buildNodesGrid(context),
    );
  }
}
