import 'package:flutter/material.dart';

/// Represents a single booking item — either a pooja or a room-only stay.
class BookingEntry {
  final String poojaName;
  final DateTime? poojaDate;
  final DateTime? checkInDate;
  final String bookingType; // 'pooja' | 'room_only'
  final String gotra;
  final int poojaAmount;   // 0 for room-only bookings
  final bool isPrivatePooja;
  final Color poojaColor;

  // Stay details (optional — 0 means no stay booked)
  final int numberOfRooms;
  final int numberOfNights;
  final int numberOfGuests;
  final int stayRatePerRoom; // per room per night
  final int? selectedRoomId;
  final String? selectedRoomName;

  const BookingEntry({
    required this.poojaName,
    this.poojaDate,
    this.checkInDate,
    this.bookingType = 'pooja',
    required this.gotra,
    required this.poojaAmount,
    required this.poojaColor,
    this.isPrivatePooja = false,
    this.numberOfRooms = 0,
    this.numberOfNights = 0,
    this.numberOfGuests = 1,
    this.stayRatePerRoom = 0,
    this.selectedRoomId,
    this.selectedRoomName,
  });

  int get stayAmount => stayRatePerRoom * numberOfRooms * numberOfNights;

  int get totalAmount => poojaAmount + stayAmount;
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
