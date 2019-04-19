import 'package:flutter/material.dart';
import 'package:gallery/app/pages/homePage.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {    
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: HomePage(),
      routes: {HomePage.routeName: (BuildContext context) => new HomePage()},
    );
  }
}