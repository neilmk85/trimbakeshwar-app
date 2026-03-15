import 'package:flutter/material.dart';

/// Represents a single pooja item in the booking cart.
class BookingEntry {
  final String poojaName;
  final DateTime poojaDate;
  final int numberOfPeople;
  final String gotra;
  final int totalAmount;
  final Color poojaColor;

  const BookingEntry({
    required this.poojaName,
    required this.poojaDate,
    required this.numberOfPeople,
    required this.gotra,
    required this.totalAmount,
    required this.poojaColor,
  });
}

/// All data collected on the BookingScreen, passed to PaymentScreen.
class BookingFormData {
  final List<BookingEntry> entries;
  final bool forMyself;
  final String? bookedForName;
  final String? bookedForPhone;
  final String? bookedForEmail;
  final String? bookedForCity;
  final String? bookedForZipCode;
  final String bookedForCountry;

  const BookingFormData({
    required this.entries,
    required this.forMyself,
    this.bookedForName,
    this.bookedForPhone,
    this.bookedForEmail,
    this.bookedForCity,
    this.bookedForZipCode,
    this.bookedForCountry = 'India',
  });

  int get grandTotal => entries.fold(0, (s, e) => s + e.totalAmount);

  Color get primaryColor =>
      entries.isNotEmpty ? entries.first.poojaColor : const Color(0xFF1565C0);
}
