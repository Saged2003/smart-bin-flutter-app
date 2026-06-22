import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'api_constants.dart';
import 'animated_button.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});
  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final TextEditingController binIdController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  bool _isLoading = false;
  Color primaryColor = const Color(0xFF0D6B58);
  Color secondaryColor = const Color(0xFFE2F3E8);

  Future<void> _updateLocation() async {
    if (binIdController.text.isEmpty || latController.text.isEmpty || lngController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('fill_all_fields'.tr())));
      return;
    }
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      var response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/employee/update-location/'),
        headers: {"Content-Type": "application/json", "Authorization": "Token $token"},
        body: jsonEncode({"bin_id": binIdController.text, "lat": double.parse(latController.text), "lng": double.parse(lngController.text)}),
      ).timeout(const Duration(seconds: 15)); 
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('location_updated'.tr()), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('update_failed'.tr()), backgroundColor: Colors.red));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('network_error'.tr()), backgroundColor: Colors.orange));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  void _useCurrentLocation() {
    latController.text = "31.2653"; 
    lngController.text = "32.3019";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('current_location_fetched'.tr())));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('employee_dashboard'.tr(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('update_bin_location'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: binIdController, decoration: InputDecoration(labelText: 'bin_id'.tr(), filled: true, fillColor: secondaryColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: latController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'latitude'.tr(), filled: true, fillColor: secondaryColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: lngController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'longitude'.tr(), filled: true, fillColor: secondaryColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedButton(
                onTap: _useCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.my_location, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('use_current_location'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : AnimatedButton(
                      onTap: _updateLocation,
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)), child: Center(child: Text('save_location'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}