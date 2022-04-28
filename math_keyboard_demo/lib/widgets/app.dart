import 'package:flutter/material.dart';
import '../data/strings.dart';
import 'scaffold.dart';

/// Demo application for `math_keyboard`.
class DemoApp extends StatefulWidget {
  /// Constructs a [DemoApp].
  const DemoApp({final Key? key}) : super(key: key);

  @override
  _DemoAppState createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  var _darkMode = false;

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber,
        ).copyWith(
          secondary: Colors.amberAccent,
        ),
      ),
      home: DemoScaffold(
        onToggleBrightness: () {
          setState(() {
            _darkMode = !_darkMode;
          });
        },
      ),
    );
  }
}
