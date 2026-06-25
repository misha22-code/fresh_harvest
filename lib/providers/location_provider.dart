// lib/providers/location_provider.dart
import 'package:flutter/material.dart';
import 'package:fresh_harvest/models/delivery_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationProvider extends ChangeNotifier {
  List<DeliveryAddress> _addresses = [];
  DeliveryAddress? _selectedAddress;

  List<DeliveryAddress> get addresses => _addresses;
  DeliveryAddress? get selectedAddress => _selectedAddress;

  LocationProvider() {
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressesJson = prefs.getString('delivery_addresses');
      if (addressesJson != null) {
        final List<dynamic> jsonList = jsonDecode(addressesJson);
        _addresses = jsonList
            .map((json) => DeliveryAddress.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _addresses.map((address) => address.toJson()).toList();
      await prefs.setString('delivery_addresses', jsonEncode(jsonList));
    } catch (e) {
      print('Error saving addresses: $e');
    }
  }

  Future<void> addAddress(DeliveryAddress address) async {
    _addresses.add(address);
    _selectedAddress = address;
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> updateAddress(DeliveryAddress address) async {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      _addresses[index] = address;
      if (_selectedAddress?.id == address.id) {
        _selectedAddress = address;
      }
      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((address) => address.id == id);
    if (_selectedAddress?.id == id) {
      _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    await _saveAddresses();
    notifyListeners();
  }

  void selectAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void clearAddresses() {
    _addresses.clear();
    _selectedAddress = null;
    notifyListeners();
  }

  DeliveryAddress? getAddressById(String id) {
    try {
      return _addresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DeliveryAddress> getAddressesByType(String type) {
    return _addresses.where((address) => address.label == type).toList();
  }
}