class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String email;
  final String phoneNumber;
  final double rating;
  final String password;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.email,
    required this.phoneNumber,
    required this.rating,
    required this.password,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'].toString(),
      name: json['name'],
      specialization: json['specialization'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      rating: json['rating'].toDouble(),
      password: json['password'],
    );
  }
}
