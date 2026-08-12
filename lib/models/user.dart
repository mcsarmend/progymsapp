// models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? number;
  final int? role; // Cambiado de type a role
  final String? image;
  final String? phone;
  final int? warehouse;
  final String? pass;
  final String? horaEntrada;
  final String? horaSalida;
  final String? fechaIngreso;
  final int? status;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.number,
    this.role,
    this.image,
    this.phone,
    this.warehouse,
    this.pass,
    this.horaEntrada,
    this.horaSalida,
    this.fechaIngreso,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      number: json['number'],
      role: json['role'], // El campo 'role' de la API
      image: json['image'],
      phone: json['phone'],
      warehouse: json['warehouse'],
      pass: json['pass'],
      horaEntrada: json['hora_entrada'],
      horaSalida: json['hora_salida'],
      fechaIngreso: json['fecha_ingreso'],
      status: json['status'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Método para verificar si es repartidor (role 5 según tu API)
  bool get isRepartidor => role == 5;

  // Método para verificar si es vendedor
  bool get isVendedor => role == 1; // Ajusta según tus roles

  // Método para verificar si es administrador
  bool get isAdmin => role == 0; // Ajusta según tus roles
}
