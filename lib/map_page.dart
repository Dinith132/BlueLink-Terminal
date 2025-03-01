import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert'; // Import dart:convert to handle JSON
import 'database_page.dart';
import 'database_helper.dart'; // Make sure to import DatabaseHelper

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Map<String, dynamic> _messages = {};
  Map<String, dynamic> _msg = {}; // New map variable to store 'our_location'
  Map<String, dynamic> _ourLocation = {}; // Variable to store 'our_location'

  @override
  void initState() {
    super.initState();
    _loaddata();
  }



  Future<void> _loaddata() async {
    var lastMessage = await DatabaseHelper().getLastMessage();
    if (lastMessage == null) return;

    if (mounted) {
      setState(() {
        _messages = lastMessage;
        if (_messages.containsKey('message')) {
          _msg = json.decode(_messages['message']); // Decode JSON string
          if (_msg.containsKey('our_location')) {
            _ourLocation = _msg['our_location'];
            print('Loaded location: $_ourLocation'); // Debug print
          } else {
            print('No our_location data found in the message'); // Debug print
          }
        } else {
          print(_messages.keys); // Debug print
        }
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    // Cancel any async task here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
      ),
      body: StreamBuilder<void>(
        stream: DatabaseHelper().messageStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            _loaddata();
          }
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _ourLocation.isNotEmpty ? _ourLocation.toString() : 'No location data',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(9.6615, 80.0255), // Use initialCenter instead of center
                    initialZoom: 13.0, // Use initialZoom instead of zoom
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _ourLocation.isNotEmpty
                            ? LatLng(_ourLocation['latitude']!, _ourLocation['longitude']!)
                            : LatLng(1.2, -0.09),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(9.353, 80.4094),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
