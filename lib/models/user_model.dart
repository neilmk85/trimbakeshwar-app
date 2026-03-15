class UserModel {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String city;
  final String pinCode;
  final String country;

  const UserModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.city,
    required this.pinCode,
    required this.country,
  });

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? city,
    String? pinCode,
    String? country,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      country: country ?? this.country,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (fullName.isNotEmpty) return fullName[0].toUpperCase();
    return 'U';
  }
}
