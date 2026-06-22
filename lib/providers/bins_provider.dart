import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class BinsProvider extends ChangeNotifier {
  List<dynamic> bins = [];
  bool isLoading = true;
  bool isOffline = false;
  String currentLocationName = "Fetching Location...";
  double currentLat = 31.2653;
  double currentLng = 32.3019;
  Future<void> loadCachedBins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedBins = prefs.getString('cached_bins');
    if (cachedBins != null) {
      bins = jsonDecode(cachedBins);
      notifyListeners();
    }
  }
  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentLocationName = "Location Disabled";
      await fetchBins(currentLat, currentLng);
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        currentLocationName = "Permission Denied";
        await fetchBins(currentLat, currentLng);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      currentLocationName = "Permission Denied";
      await fetchBins(currentLat, currentLng);
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLat = position.latitude;
      currentLng = position.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(currentLat, currentLng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentLocationName = "${place.locality ?? 'Unknown'}, ${place.subAdministrativeArea ?? ''}";
      }
    } catch(error) {
      currentLocationName = "Current Location";
    }
    await fetchBins(currentLat, currentLng);
  }
  Future<void> fetchBins(double lat, double lng) async {
    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/bins/?lat=$lat&lng=$lng')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('cached_bins', response.body);
        bins = jsonDecode(response.body);
        isLoading = false;
        isOffline = false;
      }
    } catch (error) {
      isLoading = false;
      isOffline = true;
    }
    notifyListeners();
  }
  void updateManualLocation(double lat, double lng) {
    currentLat = lat;
    currentLng = lng;
    currentLocationName = "Custom Location";
    fetchBins(currentLat, currentLng);
  }
}