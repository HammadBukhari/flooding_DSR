import 'package:flutter/material.dart';
import 'package:iot_assignment_1/core/models/node.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import 'package:iot_assignment_1/ui/provider/SliderProvider.dart';

import '../../locator.dart';

final _sliderformKey = GlobalKey<FormState>();


final sliderProvider = getIt<SliderProvider>();


class GlobalConnectionFormView extends StatelessWidget {
  List<int>abc;
  final provider  = getIt<NodeProvider>();
  String Ip;
  String Destination;
  @override
  Widget build(BuildContext context) {
  return Container(
  child: SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20,20,20,0),
    child:Form(
    key: _sliderformKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          //onChanged: ,
          decoration: const InputDecoration(
            labelText: 'Destination IP',
            hintText: '192.168.1.1',
          ),
          
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some value';
            }
            else{Ip=value;}
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Destination ID',
            hintText: 'A01',
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some value';
            }
            else{Destination=value;}
            return null;
          },
        ),
        Divider(height:20, color:Colors.white),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RawMaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(4.0),
                ),
                          //shape: const StadiumBorder(),
              fillColor: Colors.indigo,
              splashColor: Colors.indigo[50],
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(
                      "CONNECT",
                      maxLines: 1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            
              onPressed: () {
              // Validate will return true if the form is valid, or false if
              // the form is invalid.
              if (_sliderformKey.currentState.validate()) {
                //provider.makeGlobalConnection(Ip, Destination);
                provider.sendNewGlobalEdgeOverNetwork(Node(nid:sliderProvider.selectedNode),Destination,Ip);
                print(Ip+Destination);
                
                }
                
                }
              ), 
            ],
          ), 
        ],
      ),  
    ),
  ),
  );

}
}