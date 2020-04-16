import 'package:flutter/material.dart';
import 'package:iot_assignment_1/ui/provider/SliderProvider.dart';
import 'package:iot_assignment_1/ui/views/globalEdgeForm_view.dart';
import 'package:iot_assignment_1/ui/views/sliderForm_view.dart';

import '../../locator.dart';



  
class TabBarDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyTabsView();
  }
}


class _MyTabsView extends State<TabBarDemo> {
  final sliderProvider = getIt<SliderProvider>();
  int _selectedIndexForTabBar = 0;
  //1
  List<Widget> pageList = List<Widget>();

   @override
  void initState() {
    pageList.add(FormView());
    pageList.add(GlobalConnectionFormView());
    super.initState();
  }

 
 void _onItemTappedForTabBar(int index) {
    setState(() {
      _selectedIndexForTabBar = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: DefaultTabController(
      
        length: 2,
        child: Scaffold(
          
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            bottom: TabBar(
              indicatorWeight: 5,
              indicatorColor: Colors.indigo,
              indicatorSize: TabBarIndicatorSize.label,
              onTap: _onItemTappedForTabBar,
              tabs: [
                Tab(icon: Icon(Icons.directions_car,color: Colors.grey,)),
                Tab(icon: Icon(Icons.local_airport,color: Colors.grey)),
              ]
            ),
            
            title: Text(
          _selectedIndexForTabBar == 0 ? 'Create Local Edge' : 'Create Global Edge'
          ),
           textTheme: TextTheme(
            title: TextStyle(
                color: Colors.black54,
                fontSize: 24.0,
                )),
          ),
          
          body: TabBarView(
            children: [
              FormView(),
              GlobalConnectionFormView(),
            ],
          ),
        ),
      ),
    );
}
}