import 'package:flutter/widgets.dart';

import 'package:iot_assignment_1/core/models/node.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SliderProvider extends ChangeNotifier{
  PanelController pc = new PanelController();
  String selectedNode = null;
  void selectAndOpenSlider(String node){
    if (node != null){
      selectedNode = node;
      pc.open();
    }
  }
}
