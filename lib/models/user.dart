class User {
  final int id;
  final String name;
  final String email;
  final String? number;
  final String? type;
  final String? image;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.number,
    this.type,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      number: json['number'],
      type: json['type'],
      image: json['image'],
    );
  }
}
