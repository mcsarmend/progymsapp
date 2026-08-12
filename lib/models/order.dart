// models/order.dart
class Order {
  final int id;
  final String? fecha;
  final String? nota;
  final int? vendedor;
  final int? cliente;
  final double? total;
  final String? estatus;
  final String? metodoPago;
  final int? repartidor;
  final String? repartidorNombre;
  final String? clienteNombre;
  final String? clienteSucursal;
  final String? clienteTelefono;
  final String? clientePrecio;
  final String? clienteEjecutivo;
  final String? clienteEstatus;
  final String? direccion;
  final String? latitud;
  final String? longitud;
  final List<dynamic>? productos;

  Order({
    required this.id,
    this.fecha,
    this.nota,
    this.vendedor,
    this.cliente,
    this.total,
    this.estatus,
    this.metodoPago,
    this.repartidor,
    this.repartidorNombre,
    this.clienteNombre,
    this.clienteSucursal,
    this.clienteTelefono,
    this.clientePrecio,
    this.clienteEjecutivo,
    this.clienteEstatus,
    this.direccion,
    this.latitud,
    this.longitud,
    this.productos,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      fecha: json['fecha'],
      nota: json['nota'],
      vendedor: json['vendedor'],
      cliente: json['cliente'],
      total: json['total'] != null
          ? double.tryParse(json['total'].toString())
          : null,
      estatus: json['estatus'],
      metodoPago: json['metodo_pago'],
      repartidor: json['repartidor'],
      repartidorNombre: json['repartidor_nombre'],
      clienteNombre: json['cliente_nombre'],
      clienteSucursal: json['cliente_sucursal'],
      clienteTelefono: json['cliente_telefono'],
      clientePrecio: json['cliente_precio'],
      clienteEjecutivo: json['cliente_ejecutivo'],
      clienteEstatus: json['cliente_estatus'],
      direccion: json['direccion'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      productos: json['productos'] != null ? json['productos'] as List : [],
    );
  }

  // Getter para saber si tiene ubicación
  bool get hasLocation => latitud != null && longitud != null;

  // Getter para saber si tiene dirección
  bool get hasAddress => direccion != null && direccion!.isNotEmpty;
}
