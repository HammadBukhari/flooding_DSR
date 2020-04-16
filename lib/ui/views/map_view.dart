import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iot_assignment_1/core/enum/node_state.dart';
import 'package:iot_assignment_1/core/models/packet.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import 'package:iot_assignment_1/locator.dart';
import 'package:iot_assignment_1/ui/provider/SliderProvider.dart';
import 'package:iot_assignment_1/ui/widgets/buildEdges.dart'; 



class HomeMapView extends StatelessWidget {
  final nodeProvider = getIt<NodeProvider>();
  final sliderProvider = getIt<SliderProvider>();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: nodeProvider.nodes.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (BuildContext context, int index) {
        return StreamBuilder<Either<NodeState, Packet>>(
            stream: nodeProvider.nodes[index].nodeStatusStream,
            builder: (context, snapshot) {
              
              var color = const Color(0xFFe7d4cc);
              if (snapshot.hasData) {
                snapshot.data.fold((l) {
                  
                  if (l == NodeState.connectionEstablished) {
                    color = const Color(0xFF997782);
                  }
                  if (l == NodeState.packetDrop) {
                    color = const Color(0xFF535c60);
                  }
                  if (l == NodeState.busy) {
                    color = const Color(0xFFf17b7c);
                  }
                  if (l == NodeState.routeReply) {
                    color = const Color(0xFFfb991a);
                  }
                  if (l == NodeState.connectionLoss) {
                    color = const Color(0xFFb1bfcf);
                  }
                },

                (r) {
                  color = const Color(0xFF885574);
                  Fluttertoast.showToast(msg: r.message);
                }
                );
              }
              return Card(
            color: color,
            child: new InkWell(
              onTap: () {
                // getNodeDetails(nodeProvider.nodes[index].nid);
                sliderProvider.selectAndOpenSlider(nodeProvider.nodes[index].nid);
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
                          nodeProvider.nodes[index].nid,
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),);
                  if (nodeProvider.nodes[index].hasLeftEdge())
                  stackWidgets.add(Align(
                        alignment: Alignment.centerLeft,
                        child: buildVerticalNode(context),
                      ),);
                  if (nodeProvider.nodes[index].hasRightEdge())
                  stackWidgets.add(
                      Align(
                        alignment: Alignment.centerRight,
                        child: buildVerticalNode(context),
                      ),);
                  if (nodeProvider.nodes[index].hasUpEdge())
                  stackWidgets.add(Align(
                        alignment: Alignment.topCenter,
                        child: buildHorizontalNode(context),
                      ),);
                  if (nodeProvider.nodes[index].hasDownEdge())
                  stackWidgets.add(Align(
                        alignment: Alignment.bottomCenter,
                        child: buildHorizontalNode(context),
                      ),);
                  
                  return Stack(
                    children: stackWidgets
                  );
                }
                ),
                alignment: Alignment(0.0, 0.0),
                  ),
                ),
              );
            
            }
            );
      },
    );
  }
}
