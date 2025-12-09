import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'favorites_page.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Charge le JSON
    String jsonString = await rootBundle.loadString('assets/anime_1000.json');
    List<dynamic> animeList = jsonDecode(jsonString);

    
    await Future.delayed(Duration(seconds: 1));

    // Naviguer vers ta page principale
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => FavoritesPage(animeData: animeList)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ton animation JSON si tu veux
            CircularProgressIndicator(color: Colors.white), 
            SizedBox(height: 20),
            Text(
              "Chargement...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
