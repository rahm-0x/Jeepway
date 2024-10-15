import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '../utils/constants.dart'; // Import constants like cityCoordinates and jeepney data
import '../widgets/map_widget.dart';
import '../widgets/dropdown_city.dart';
import 'login_signup_page.dart';
import 'add_jeep_page.dart'; // Add jeep form page
import 'manage_fleet_page.dart'; // Manage fleet page

class JeepwayHomePage extends StatefulWidget {
  @override
  _JeepwayHomePageState createState() => _JeepwayHomePageState();
}

class _JeepwayHomePageState extends State<JeepwayHomePage> {
  String _selectedCity = 'Cebu';
  bool _isLoggedIn = false; // Simulating login state
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                _isLoggedIn ? 'Welcome, User' : 'Please Login/Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            if (!_isLoggedIn)
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Login/Register'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginSignupPage()),
                  );
                  // Simulate login after returning
                  setState(() {
                    _isLoggedIn =
                        true; // Mark as logged in after returning from login page
                  });
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: Icon(Icons.directions_car),
                title: Text('Add Jeep'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddJeepPage()),
                  );
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Manage Fleet'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageFleetPage()),
                  );
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  // Simulate logout by changing the state
                  setState(() {
                    _isLoggedIn = false; // Mark as logged out
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Jeepway',
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CityDropdown(
              selectedCity: _selectedCity,
              onCityChanged: (newCity) {
                setState(() {
                  _selectedCity = newCity!;
                  _mapController.move(cityCoordinates[_selectedCity]!, 13.0);
                });
              },
            ),
          ),
          Expanded(
            child: MapWidget(
              mapController: _mapController,
              popupController: _popupController,
              selectedCity: _selectedCity,
            ),
          ),
        ],
      ),
    );
  }
}
