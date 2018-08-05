import 'package:flutter/material.dart';
import 'package:no_to_do/ui/notodoscreen.dart';


class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("NO TO DO"),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: new NoToDoScreen(),
    );
  }
}
