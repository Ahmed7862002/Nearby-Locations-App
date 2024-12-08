import 'package:flutter/material.dart';
import 'Favourites.dart';
import 'LocationPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/Home',
      routes: {
        '/Home': (context) => LocationScreen(),
        '/favourites': (context) => FavouritesPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

