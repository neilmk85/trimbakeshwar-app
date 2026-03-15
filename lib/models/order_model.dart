import 'package:flutter/material.dart';

class OrderModel {
  final String orderId;
  final String poojaName;
  final DateTime poojaDate;
  final int numberOfPeople;
  final String gotra;
  final int totalAmount;
  final DateTime bookedOn;
  final Color poojaColor;
  final String? bookedForName;
  final String? bookedForPhone;
  final String? bookedForEmail;
  final String? bookedForCity;
  final String? bookedForZipCode;
  final String? bookedForCountry;
  final bool cancelled;

  const OrderModel({
    required this.orderId,
    required this.poojaName,
    required this.poojaDate,
    required this.numberOfPeople,
    required this.gotra,
    required this.totalAmount,
    required this.bookedOn,
    required this.poojaColor,
    this.bookedForName,
    this.bookedForPhone,
    this.bookedForEmail,
    this.bookedForCity,
    this.bookedForZipCode,
    this.bookedForCountry,
    this.cancelled = false,
  });
}
