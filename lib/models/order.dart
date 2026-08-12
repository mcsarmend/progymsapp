// models/order.dart

import 'package:flutter/material.dart';
import 'dart:convert';

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
  final int? clienteSucursal;
  final String? clienteTelefono;
  final int? clientePrecio;
  final String? clienteEjecutivo;
  final int? clienteEstatus;
  final String? direccion;
  final String? latitud;
  final String? longitud;
  final List<Map<String, dynamic>>? productos;

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
      id: _parseInt(json['id']),
      fecha: _parseString(json['fecha']),
      nota: _parseString(json['nota']),
      vendedor: _parseIntNullable(json['vendedor']),
      cliente: _parseIntNullable(json['cliente']),
      total: _parseDoubleNullable(json['total']),
      estatus: _parseString(json['estatus']),
      metodoPago: _parseString(json['metodo_pago']),
      repartidor: _parseIntNullable(json['repartidor']),
      repartidorNombre: _parseString(json['repartidor_nombre']),
      clienteNombre: _parseString(json['cliente_nombre']),
      clienteSucursal: _parseIntNullable(json['cliente_sucursal']),
      clienteTelefono: _parseString(json['cliente_telefono']),
      clientePrecio: _parseIntNullable(json['cliente_precio']),
      clienteEjecutivo: _parseString(json['cliente_ejecutivo']),
      clienteEstatus: _parseIntNullable(json['cliente_estatus']),
      direccion: _parseString(json['direccion']),
      latitud: _parseString(json['latitud']),
      longitud: _parseString(json['longitud']),
      productos: _parseProductos(json['productos']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static List<Map<String, dynamic>>? _parseProductos(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return value.map((item) => Map<String, dynamic>.from(item)).toList();
      } catch (e) {
        return [];
      }
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // Método para obtener el nombre del producto con manejo de campos
  String _getProductoNombre(Map<String, dynamic> producto) {
    // Intentar con diferentes nombres de campo
    return producto['Nombre'] ??
        producto['nombre'] ??
        producto['name'] ??
        producto['Producto'] ??
        'Producto sin nombre';
  }

  // Método para obtener la cantidad del producto
  int _getProductoCantidad(Map<String, dynamic> producto) {
    final cantidadItem = producto['Cantidad'] ?? producto['cantidad'];
    if (cantidadItem is num) return cantidadItem.toInt();
    if (cantidadItem is String) return int.tryParse(cantidadItem) ?? 1;
    return 1;
  }

  // Método para obtener el precio del producto
  double _getProductoPrecio(Map<String, dynamic> producto) {
    final precioItem =
        producto['Precio Unitario'] ?? producto['precio'] ?? producto['Precio'];
    if (precioItem is num) return precioItem.toDouble();
    if (precioItem is String) {
      // Limpiar el precio (quitar $ y espacios)
      final cleaned =
          precioItem.replaceAll('\$', '').replaceAll(' ', '').trim();
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  // Método para obtener el subtotal del producto
  double _getProductoSubtotal(Map<String, dynamic> producto) {
    final subtotalItem =
        producto['Subtotal'] ?? producto['subtotal'] ?? producto['Total'];
    if (subtotalItem is num) return subtotalItem.toDouble();
    if (subtotalItem is String) {
      final cleaned =
          subtotalItem.replaceAll('\$', '').replaceAll(' ', '').trim();
      return double.tryParse(cleaned) ?? 0;
    }
    // Si no hay subtotal, calcularlo
    return _getProductoCantidad(producto) * _getProductoPrecio(producto);
  }

  // Método para obtener el código del producto
  String? _getProductoCodigo(Map<String, dynamic> producto) {
    return producto['Codigo'] ?? producto['codigo'] ?? producto['code'] ?? null;
  }

  // Método para obtener la sucursal del producto
  String? _getProductoSucursal(Map<String, dynamic> producto) {
    return producto['Sucursal'] ??
        producto['sucursal'] ??
        producto['warehouse'] ??
        null;
  }

  // Getters para estados
  bool get isSurtido => estatus == 'SURTIDO';
  bool get isRevisado => estatus == 'REVISADO';
  bool get isEnRuta => estatus == 'EN RUTA';
  bool get isEntregado => estatus == 'ENTREGADO';
  bool get isCancelado => estatus == 'CANCELADO';
  bool get isFinalizado => estatus == 'FINALIZADO';

  // Getters para agrupación
  bool get isPendiente => estatus == 'SURTIDO' || estatus == 'REVISADO';
  bool get isEnProceso => estatus == 'EN RUTA';
  bool get isCompletado => estatus == 'ENTREGADO' || estatus == 'FINALIZADO';
  bool get isCanceladoOrFinalizado =>
      estatus == 'CANCELADO' || estatus == 'FINALIZADO';

  bool get hasLocation => latitud != null && longitud != null;
  bool get hasAddress => direccion != null && direccion!.isNotEmpty;

  String get statusLabel {
    switch (estatus) {
      case 'SURTIDO':
        return 'Surtido';
      case 'REVISADO':
        return 'Revisado';
      case 'EN RUTA':
        return 'En ruta';
      case 'ENTREGADO':
        return 'Entregado';
      case 'CANCELADO':
        return 'Cancelado';
      case 'FINALIZADO':
        return 'Finalizado';
      default:
        return estatus ?? 'Sin estado';
    }
  }

  Color get statusColor {
    switch (estatus) {
      case 'SURTIDO':
        return Colors.orange;
      case 'REVISADO':
        return Colors.purple;
      case 'EN RUTA':
        return Colors.indigo;
      case 'ENTREGADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      case 'FINALIZADO':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String get statusIcon {
    switch (estatus) {
      case 'SURTIDO':
        return '📦';
      case 'REVISADO':
        return '✅';
      case 'EN RUTA':
        return '🚚';
      case 'ENTREGADO':
        return '📍';
      case 'CANCELADO':
        return '❌';
      case 'FINALIZADO':
        return '🏁';
      default:
        return '❓';
    }
  }

  List<Map<String, String>> getAvailableActions() {
    if (isPendiente) {
      return [
        {'label': 'EN RUTA', 'action': 'EN RUTA', 'color': 'indigo'},
        {'label': 'CANCELAR', 'action': 'CANCELADO', 'color': 'red'},
      ];
    }

    if (isEnRuta) {
      return [
        {'label': 'ENTREGAR', 'action': 'ENTREGADO', 'color': 'green'},
        {'label': 'CANCELAR', 'action': 'CANCELADO', 'color': 'red'},
      ];
    }

    return [];
  }

  // Método para obtener el total de productos
  double get totalProductos {
    if (productos == null) return 0;
    double total = 0;
    for (var producto in productos!) {
      total += _getProductoSubtotal(producto);
    }
    return total;
  }

  // Método para obtener la cantidad total de productos
  int get cantidadProductos {
    if (productos == null) return 0;
    int cantidad = 0;
    for (var producto in productos!) {
      cantidad += _getProductoCantidad(producto);
    }
    return cantidad;
  }

  // Método para obtener la lista de productos formateada
  List<Map<String, dynamic>> get productosFormateados {
    if (productos == null) return [];
    return productos!.map((producto) {
      return {
        'nombre': _getProductoNombre(producto),
        'codigo': _getProductoCodigo(producto) ?? 'N/A',
        'cantidad': _getProductoCantidad(producto),
        'precio': _getProductoPrecio(producto),
        'subtotal': _getProductoSubtotal(producto),
        'sucursal': _getProductoSucursal(producto) ?? 'Sin sucursal',
        'original': producto,
      };
    }).toList();
  }

  @override
  String toString() {
    return 'Order(id: $id, cliente: $clienteNombre, estatus: $estatus, total: $total)';
  }
}
