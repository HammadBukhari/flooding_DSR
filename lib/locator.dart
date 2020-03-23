import 'package:get_it/get_it.dart';
import 'package:iot_assignment_1/core/view_models/node_provider.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<NodeProvider>(NodeProvider());
}
