import 'package:flutter/widgets.dart';
import 'package:url_strategy/url_strategy.dart';

import 'widgets/app.dart';

void main() {
  setPathUrlStrategy();
  runApp(const DemoApp());
}
