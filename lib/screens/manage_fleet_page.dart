import 'package:flutter/material.dart';
import '../models/jeepney_model.dart';

class ManageFleetPage extends StatelessWidget {
  // Example of added jeeps (in real cases, store in a list)
  final List<Jeepney> jeepneys = [
    Jeepney(routeNumber: '17B', seats: 20, nickname: 'Speedy'),
    Jeepney(routeNumber: '23C', seats: 25, nickname: 'Turbo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Fleet'),
      ),
      body: ListView.builder(
        itemCount: jeepneys.length,
        itemBuilder: (context, index) {
          final jeep = jeepneys[index];
          return ListTile(
            title: Text('${jeep.routeNumber} - ${jeep.nickname}'),
            subtitle: Text('Seats: ${jeep.seats}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Add delete logic here
              },
            ),
          );
        },
      ),
    );
  }
}
