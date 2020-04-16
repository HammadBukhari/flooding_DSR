import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import '../../locator.dart';
final _formKey = GlobalKey<FormState>();


class SettingsView extends StatelessWidget {
  final provider = getIt<NodeProvider>();
  String mobility;
  String packetLoss;
  String deviceIdentifier;
  @override
  Widget build(BuildContext context) {
  return Container(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child:Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Node Mobility',
            hintText: '0-100 with 0 showing least mobility',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some value';
            }
            else
              mobility=value;
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Packet Loss',
            hintText: '0-100 with 0 showing least packet loss',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some value';
            }
            else
              packetLoss=value;
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Device Identifier',
            hintText: 'Enter any alphabet',
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter any alphabet';
            }
            else
              deviceIdentifier=value;
            return null;
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: RaisedButton(
            onPressed: () {
              // Validate will return true if the form is valid, or false if
              // the form is invalid.
              if (_formKey.currentState.validate()) {
                provider.setDeviceIdentifier(deviceIdentifier);
                print(deviceIdentifier);
                provider.setMobilityProbability(mobility);
                provider.setPacketDropProbability(packetLoss);
                // Process data.
              }
            },
            child: Text('Submit'),
          ),
        ),
      ],
    ),
  ),
),
);
  }

  
}
 