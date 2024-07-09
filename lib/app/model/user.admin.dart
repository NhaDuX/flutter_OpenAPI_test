class UserA {
  final String numberID;
  final String accountID;
  final String? imageUrl; // Có thể null
  final String fullName;
  final String birthDay;
  final String gender;
  final String dateCreated;
  final String phoneNumber;
  final bool locked;
  final String password;
  final bool active;
  final String schoolYear;
  final String schoolKey;

  UserA({
    required this.numberID,
    required this.accountID,
    this.imageUrl, // Có thể null
    required this.fullName,
    required this.birthDay,
    required this.gender,
    required this.dateCreated,
    required this.phoneNumber,
    required this.locked,
    required this.password,
    required this.active,
    required this.schoolYear,
    required this.schoolKey,
  });

  factory UserA.fromJson(Map<String, dynamic> json) {
    return UserA(
      numberID: json['numberID'] ?? '',
      accountID: json['accountID'] ?? '',
      imageUrl: json['imageUrl'], // Có thể null
      fullName: json['fullName'] ?? '',
      birthDay: json['birthDay'] ?? '',
      gender: json['gender'] ?? '',
      dateCreated: json['dateCreated'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      locked: json['locked'] ?? false,
      password: json['password'] ?? '',
      active: json['active'] ?? false,
      schoolYear: json['schoolYear'] ?? '',
      schoolKey: json['schoolKey'] ?? '',
    );
  }
}
