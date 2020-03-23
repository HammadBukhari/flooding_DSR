import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:iot_assignment_1/locator.dart';

import 'core/view_models/node_provider.dart'; // connectivity

void main() {
  setup();
  var provider = getIt<NodeProvider>();
  provider.initNodes();
  for (var node in provider.nodes) {
    print("${node.toString()}\n");
    
  }
}
