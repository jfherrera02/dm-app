import 'package:dmessages/components/my_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      // little menu bar (change for a modern menu later)
      drawer: MyDrawer(),
    );
  }
}