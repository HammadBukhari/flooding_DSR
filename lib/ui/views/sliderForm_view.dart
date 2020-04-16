import 'package:flutter/material.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import 'package:iot_assignment_1/ui/provider/SliderProvider.dart';
import '../../locator.dart';
import '../../main.dart';


final _sliderformKey = GlobalKey<FormState>();


final sliderProvider = getIt<SliderProvider>();


class FormView extends StatelessWidget {

  
  final provider  = getIt<NodeProvider>();
  String Ip;
  String Msg;
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
          //controller: ,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Type Your Mesage',
          ),
          
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            else{Msg=value;}
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
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Destination Device IP',
        //     hintText: '127.0.0.1',
        //   ),
        //   validator: (value) {
        //     if (value.isEmpty) {
        //       return 'Please enter destination IP';
        //     }
        //     else{Ip=value;}
        //     return null;
        //   },
        // ),
        Divider(height:20, color:Colors.white),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RawMaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0),
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
                      "FLOODING",
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
                provider.flood(sliderProvider.selectedNode,Destination,Msg);
                print(Ip+Destination);
              }
              
              }
            ), 
              RawMaterialButton(
              fillColor: Colors.indigo,
              splashColor: Colors.indigo[50],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(4.0),
                ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(
                      "DSR",
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
                provider.makeDSRRreq(sliderProvider.selectedNode,Destination,Msg);
                main();
              }
              }
            ),
          ],
        )
        
      ],
    ),  
  ),
),
);
  }

  
}
