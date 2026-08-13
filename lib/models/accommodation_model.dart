class AccommodationModel {
  final int totalRooms;
  final int personsPerRoom;
  final int pricePerRoom;
  final int pricePerPerson;

  const AccommodationModel({
    required this.totalRooms,
    required this.personsPerRoom,
    required this.pricePerRoom,
    required this.pricePerPerson,
  });

  static const empty = AccommodationModel(
    totalRooms: 0,
    personsPerRoom: 2,
    pricePerRoom: 0,
    pricePerPerson: 0,
  );

  bool get available => totalRooms > 0;

  /// Total cost for [rooms] rooms for [nights] nights.
  int costFor({required int rooms, required int nights}) =>
      rooms * (pricePerRoom + personsPerRoom * pricePerPerson) * nights;

  factory AccommodationModel.fromJson(Map<String, dynamic> json) =>
      AccommodationModel(
        totalRooms: (json['totalRooms'] as num?)?.toInt() ?? 0,
        personsPerRoom: (json['personsPerRoom'] as num?)?.toInt() ?? 2,
        pricePerRoom: (json['pricePerRoom'] as num?)?.toInt() ?? 0,
        pricePerPerson: (json['pricePerPerson'] as num?)?.toInt() ?? 0,
      );
}
