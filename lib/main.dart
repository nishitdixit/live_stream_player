import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'screens/video_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
              sliderTheme: SliderTheme.of(context).copyWith(
                //slider modifications
                thumbColor: Color(0xFFEB1555),
                inactiveTrackColor: Color(0xFF8D8E98),
                activeTrackColor: Colors.white,
                overlayColor: Color(0x99EB1555),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
              ),
              primaryColor: Color(0xFF0A0E21), // theme color
              scaffoldBackgroundColor: Color(0xFF0A0E21)),
          title: 'Video Demo',
          home: VideoListPage()),
    );
  }
}
