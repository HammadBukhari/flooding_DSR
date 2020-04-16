import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iot_assignment_1/core/enum/packet_type.dart';
import 'package:iot_assignment_1/locator.dart';
import 'package:iot_assignment_1/ui/provider/SliderProvider.dart';
import 'package:iot_assignment_1/ui/views/tabbedForm_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'core/view_models/node_provider.dart'; // connectivity
import 'ui/views/map_view.dart';
import 'ui/views/settings_view.dart';
final provider = getIt<NodeProvider>();


void main() {
  setup();
  WidgetsFlutterBinding.ensureInitialized();
  final deviceId = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"];
  provider.setDeviceIdentifier(deviceId[Random().nextInt(deviceId.length)]);
  provider.initNodes(AlgorithmType.DSR);
  provider.initNetwork();

  runApp(MyApp());
}



class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePage();
  }
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

class _MyHomePage extends State<MyHomePage> {
  final sliderProvider = getIt<SliderProvider>();
  int _selectedIndexForBottomNavigationBar = 0;
  //1
  List<Widget> pageList = List<Widget>();

   @override
  void initState() {
    pageList.add(HomeMapView());
    pageList.add(SettingsView());
    super.initState();
  }

 

  //2
  void _onItemTappedForBottomNavigationBar(int index) {
    setState(() {
      _selectedIndexForBottomNavigationBar = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    //3
    return new Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.white,

         title: FutureBuilder(
          future: provider.getDeviceLocalIp(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData)
              return Text(snapshot.data.toString());
            else
              return CircularProgressIndicator();
          },
        ),


        // title: Text(

        //   _selectedIndexForBottomNavigationBar == 0 ? 'My Nodes' : 'Settings'

        // ),
        textTheme: TextTheme(
            title: TextStyle(
                color: Colors.black54,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 3)),
      ),
      body: SlidingUpPanel(
        panel: _floatingPanel(),
        collapsed: _floatingCollapsed(),
        controller : sliderProvider.pc,
        maxHeight: 350,
        minHeight: 40,
        body: IndexedStack(
          index: _selectedIndexForBottomNavigationBar,
          children: pageList,
        ),
        // SizedBox.shrink(
        //     child: _listOfIconsForBottomNavigationBar
        //         .elementAt(_selectedIndexForBottomNavigationBar)),
       borderRadius: radius,
        
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap:
            _onItemTappedForBottomNavigationBar, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.directions_boat), title: Text('Home')),
          BottomNavigationBarItem(
              icon: new Icon(Icons.settings), title: Text('Settings')),
        ],
        currentIndex: _selectedIndexForBottomNavigationBar,
      ),
    );
  }

  Widget _floatingCollapsed(){
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(24.0))
    ),
    
    child: Center(
      child: Text(
        "Tap on any node to send a message",
        style: TextStyle(color: Colors.grey),
      ),
    ),
  );
}

Widget _floatingPanel(){
  return Container(
    margin: const EdgeInsets.fromLTRB(24.0,24,24,0),
    child: Center(
      child: TabBarDemo(),
    ),
  );
}
}
