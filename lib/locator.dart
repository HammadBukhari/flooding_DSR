import 'package:get_it/get_it.dart';
import 'package:iot_assignment_1/core/services/flooding.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';
import 'package:iot_assignment_1/ui/provider/SliderProvider.dart';


final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<NodeProvider>(NodeProvider());
  getIt.registerSingleton<Flooding>(Flooding());
  getIt.registerSingleton<SliderProvider>(SliderProvider());

}
