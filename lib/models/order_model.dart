import 'package:flutter/material.dart';

class OrderModel {
  final String orderId;
  final String poojaName;
  final DateTime? poojaDate;
  final DateTime? checkInDate;
  final String bookingType;
  final String gotra;
  final int numberOfPeople;
  final int poojaRatePerPerson;
  final int totalAmount;
  final int numberOfRooms;
  final int numberOfNights;
  final int stayRatePerRoom;
  final DateTime bookedOn;
  final Color poojaColor;
  final String? bookedForName;
  final String? bookedForPhone;
  final String? bookedForEmail;
  final String? bookedForCity;
  final String? bookedForZipCode;
  final String? bookedForCountry;
  final bool cancelled;
  final bool rescheduled;
  final bool completed;
  final bool confirmed;
  final bool certificateSent;
  final bool isPrivatePooja;
  final int? selectedRoomId;
  final String? selectedRoomName;
  final List<String>? familyNames;
  final String? userName;
  final String? userPhone;
  final String? razorpayOrderId;
  final String? paymentId;

  bool get isRoomOnly => bookingType == 'room_only';
  DateTime? get eventDate => isRoomOnly ? checkInDate : poojaDate;

  const OrderModel({
    required this.orderId,
    required this.poojaName,
    this.poojaDate,
    this.checkInDate,
    this.bookingType = 'pooja',
    required this.gotra,
    required this.totalAmount,
    required this.bookedOn,
    required this.poojaColor,
    this.numberOfPeople = 1,
    this.poojaRatePerPerson = 0,
    this.numberOfRooms = 0,
    this.numberOfNights = 0,
    this.stayRatePerRoom = 0,
    this.bookedForName,
    this.bookedForPhone,
    this.bookedForEmail,
    this.bookedForCity,
    this.bookedForZipCode,
    this.bookedForCountry,
    this.cancelled = false,
    this.rescheduled = false,
    this.completed = false,
    this.confirmed = false,
    this.certificateSent = false,
    this.isPrivatePooja = false,
    this.selectedRoomId,
    this.selectedRoomName,
    this.familyNames,
    this.userName,
    this.userPhone,
    this.razorpayOrderId,
    this.paymentId,
  });
}
