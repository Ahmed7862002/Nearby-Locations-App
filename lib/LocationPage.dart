import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Favourites.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _location = "No location detected";
  List<Map<String, String>> _addresses = [];
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveFavorite(Map<String, String> address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedFavorites = prefs.getStringList('favorites') ?? [];
    String favorite = '${address['address']}'; 
    if (!savedFavorites.contains(favorite)) {
      savedFavorites.add(favorite);
      await prefs.setStringList('favorites', savedFavorites);
    }
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _location = "Permission Denied";
        _addresses = [];
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      Position modifiedPosition = Position(
        latitude: 30.043400,
        longitude: 31.235200,
        timestamp: position.timestamp,
        altitude: position.altitude,
        accuracy: position.accuracy,
        heading: position.heading,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        altitudeAccuracy: position.altitudeAccuracy,
        headingAccuracy: position.headingAccuracy,
      );

      setState(() {
        _latitude = modifiedPosition.latitude;
        _longitude = modifiedPosition.longitude;
        _location = 'Latitude: ${_latitude}, Longitude: ${_longitude}';
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(modifiedPosition.latitude, modifiedPosition.longitude);
      setState(() {
        _addresses = placemarks.map((place) {
          return {
            'address': '${place.street}, ${place.locality}, ${place.country}',
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _location = "Failed to fetch location";
        _addresses = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Nearby Landmarks'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center( 
              child: ElevatedButton(
                onPressed: _checkPermissionsAndGetLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.white), 
                    SizedBox(width: 10), 
                    Text(
                      'Get Location',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _location != "No location detected"
                ? Center(
              child: Column(
                children: [
                  Text(
                    'Latitude: ${_latitude ?? 'Not available'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'Longitude: ${_longitude ?? 'Not available'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Address: ${_addresses.isNotEmpty ? _addresses[0]['address'] : 'No Addresses to show'}',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          if (_addresses.isNotEmpty) {
                            _saveFavorite(_addresses[0]);
                          }
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                : Text(
              _location,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 20),
            _addresses.isEmpty
                ? SizedBox()
                : Expanded(
              child: ListView.builder(
                shrinkWrap: true, 
                physics: NeverScrollableScrollPhysics(), 
                itemCount: _addresses.length - 1, 
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.grey.shade300,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded( 
                            child: Text(
                              '${_addresses[index + 1]['address']}', 
                              style: TextStyle(
                                fontSize: 14, 
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              _saveFavorite(_addresses[index + 1]); 
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
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
            Navigator.pushNamed(context, '/favourites');
          }
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/Home');
          }
        },
      ),
    );
  }
}
