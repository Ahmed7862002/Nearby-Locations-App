import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  late Future<List<String>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = _loadFavorites();
  }

  Future<List<String>> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedFavorites = prefs.getStringList('favorites');
    if (savedFavorites != null) {
      return savedFavorites;
    } else {
      return [];
    }
  }

  Future<void> _removeFavorite(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedFavorites = prefs.getStringList('favorites') ?? [];
    savedFavorites.remove(address);
    await prefs.setStringList('favorites', savedFavorites);
    setState(() {
      _favorites = _loadFavorites();  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Locations'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<String>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                        title: Text(
                          snapshot.data![index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _removeFavorite(snapshot.data![index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Text(
                  'No favorite locations found.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favourites');
          }
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
