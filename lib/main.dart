import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:iot_assignment_1/locator.dart';

import 'core/enum/node_state.dart';
import 'core/models/packet.dart';
import 'core/services/flooding.dart';
import 'core/view_models/node_provider.dart'; // connectivity

final _formKey = GlobalKey<FormState>();

void main() {
  setup();

  var provider = getIt<NodeProvider>();
  provider.initNodes();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
              var color = Colors.grey;
              if (snapshot.hasData) {
                snapshot.data.fold((l) {
                  if (l == NodeState.busy) {
                    color = Colors.red;
                  }
                }, (r) => color = Colors.green);
              }
              return Card(
            color: color,
            child: new InkWell(
              onTap: () {
                print("tapped");
              },
              child: Container(
                width: 100.0,
                height: 100.0,
                padding: const EdgeInsets.all(8),
                child: Builder(builder: (BuildContext context) {
                  var stackWidgets = <Widget>[];
                  stackWidgets.add(Align(
                        alignment: Alignment.center,
                        child: new Text(
                          provider.nodes[index].nid,
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),);
                  if (provider.nodes[index].hasLeftEdge())
                  stackWidgets.add(Align(
                        alignment: Alignment.centerLeft,
                        child: buildVerticalNode(context),
                      ),);
                  if (provider.nodes[index].hasRightEdge())
                  stackWidgets.add(
                      Align(
                        alignment: Alignment.centerRight,
                        child: buildVerticalNode(context),
                      ),);
                  if (provider.nodes[index].hasUpEdge())
                  stackWidgets.add(Align(
                        alignment: Alignment.topCenter,
                        child: buildHorizontalNode(context),
                      ),);
                  if (provider.nodes[index].hasDownEdge())
                  stackWidgets.add(Align(
                        alignment: Alignment.bottomCenter,
                        child: buildHorizontalNode(context),
                      ),);
                  
                  return Stack(
                    children: stackWidgets
                  );
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
          provider.flood('A01', "A33", Packet(message: "Hello"));
        },
      ),
      appBar: AppBar(),
      body: buildNodesGrid(context),
    );
  }
}
