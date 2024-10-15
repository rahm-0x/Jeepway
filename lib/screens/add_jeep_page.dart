import 'package:flutter/material.dart';
import '../models/jeepney_model.dart';

class AddJeepPage extends StatefulWidget {
  @override
  _AddJeepPageState createState() => _AddJeepPageState();
}

class _AddJeepPageState extends State<AddJeepPage> {
  final _formKey = GlobalKey<FormState>();
  String? _routeNumber;
  int? _seats;
  String? _nickname;
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Jeep'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Route Number'),
                items: ['17B', '23C'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => _routeNumber = newValue,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Number of Seats'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _seats = int.tryParse(value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nickname'),
                onChanged: (value) => _nickname = value,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Add jeep logic
                    final newJeep = Jeepney(
                      routeNumber: _routeNumber!,
                      seats: _seats!,
                      nickname: _nickname!,
                      imagePath: _imagePath,
                    );
                    print('New Jeep Added: $newJeep');
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Jeep'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
