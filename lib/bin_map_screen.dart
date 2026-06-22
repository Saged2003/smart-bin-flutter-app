import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BinMapScreen extends StatelessWidget {
  final String binId;
  final double lat;
  final double lng;
  final String status;
  final double capacity;

  const BinMapScreen({super.key, required this.binId, required this.lat, required this.lng, required this.status, required this.capacity});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF0D6B58);
    bool isLow = capacity < 50;
    bool isMedium = capacity >= 50 && capacity < 80;
    Color markerColor = isLow ? Colors.green : (isMedium ? Colors.amber : Colors.red);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Bin $binId Location', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 16.0),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.smartbin.app'),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lng),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bin $binId - Capacity: ${capacity.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)))),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: markerColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {},
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}