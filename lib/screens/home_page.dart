// home_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'dart:async';

// ============================================================
// CONFIGURACIÓN DE API KEYS
// ============================================================
// Coloca aquí tus API keys
class AppConfig {
  // Google Maps API Key
  static const String googleMapsApiKey =
      'AIzaSyCI9KYYmGxX3_PpRTjvzimwhlfRmemqH7g';

  // WhatsApp API Key (si usas alguna API de WhatsApp Business)
  // Si no usas API, solo se usará el enlace directo de WhatsApp
  static const String? whatsAppApiKey = null; // 'TU_API_KEY_AQUI';

  // URL base para APIs adicionales
  static const String baseApiUrl = 'https://seges.com.mx/pedidos';
}

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  bool _loggingOut = false;

  // Variables para pedidos
  List<Order> _pedidos = [];
  List<Order> _pedidosFiltrados = [];
  bool _isLoadingPedidos = false;
  String? _errorPedidos;

  // Filtros
  String _filtroActual = 'TODOS';
  final List<String> _filtros = [
    'TODOS',
    'PENDIENTES',
    'EN RUTA',
    'ENTREGADOS',
    'CANCELADOS'
  ];

  // Estadísticas
  int _pedidosPendientes = 0;
  int _pedidosEnRuta = 0;
  int _pedidosEntregados = 0;
  int _pedidosCancelados = 0;
  int _pedidosTotales = 0;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  // ============================================================
  // MÉTODOS DE CARGA Y FILTRADO
  // ============================================================

  Future<void> _cargarPedidos() async {
    if (_isLoadingPedidos) return;

    setState(() {
      _isLoadingPedidos = true;
      _errorPedidos = null;
    });

    try {
      final pedidosData =
          await _authService.getPedidosRepartidor(widget.user.id);

      setState(() {
        _pedidos = pedidosData.map((p) => Order.fromJson(p)).toList();
        _pedidosTotales = _pedidos.length;

        _pedidosPendientes = _pedidos.where((p) => p.isPendiente).length;
        _pedidosEnRuta = _pedidos.where((p) => p.isEnRuta).length;
        _pedidosEntregados = _pedidos.where((p) => p.isEntregado).length;
        _pedidosCancelados = _pedidos.where((p) => p.isCancelado).length;

        _aplicarFiltro();
        _isLoadingPedidos = false;
      });
    } catch (e) {
      setState(() {
        _errorPedidos = e.toString();
        _isLoadingPedidos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pedidos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _aplicarFiltro() {
    setState(() {
      switch (_filtroActual) {
        case 'PENDIENTES':
          _pedidosFiltrados = _pedidos.where((p) => p.isPendiente).toList();
          break;
        case 'EN RUTA':
          _pedidosFiltrados = _pedidos.where((p) => p.isEnRuta).toList();
          break;
        case 'ENTREGADOS':
          _pedidosFiltrados = _pedidos.where((p) => p.isEntregado).toList();
          break;
        case 'CANCELADOS':
          _pedidosFiltrados = _pedidos.where((p) => p.isCancelado).toList();
          break;
        default:
          _pedidosFiltrados = List.from(_pedidos);
          break;
      }
    });
  }

  // ============================================================
  // MÉTODOS DE ACCIÓN
  // ============================================================

  // Abrir WhatsApp con el número del cliente
  Future<void> _abrirWhatsApp(String telefono, String nombreCliente) async {
    // Limpiar el número de teléfono (quitar espacios, guiones, etc.)
    String numeroLimpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');

    // Si el número no tiene código de país, agregar el de México (+52)
    if (!numeroLimpio.startsWith('52') && numeroLimpio.length == 10) {
      numeroLimpio = '52$numeroLimpio';
    }

    // Si el número no tiene el signo +, agregarlo
    if (!numeroLimpio.startsWith('+')) {
      numeroLimpio = '+$numeroLimpio';
    }

    // Mensaje predeterminado
    final mensaje = Uri.encodeComponent(
        'Hola $nombreCliente, soy tu repartidor de PROGYMS. '
        'Estoy en camino con tu pedido. ¿Hay algo más que necesites?');

    // Construir URL de WhatsApp
    final url = 'https://wa.me/$numeroLimpio?text=$mensaje';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Si no se puede abrir WhatsApp, intentar con el navegador
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } else {
          throw 'No se puede abrir WhatsApp';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Abrir Google Maps con la ubicación
  Future<void> _abrirMapa(
      String latitud, String longitud, String direccion) async {
    // URL para abrir en Google Maps
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se puede abrir el mapa';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el mapa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Abrir navegador con la ubicación
  Future<void> _abrirNavegador(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        throw 'No se puede abrir el enlace';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cambiarEstadoPedido(int pedidoId, String nuevoEstatus) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar cambio'),
          content: Text('¿Cambiar estado a "$nuevoEstatus"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
              ),
              child: const Text('CONFIRMAR'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final success =
          await _authService.cambiarEstadoPedido(pedidoId, nuevoEstatus);

      if (success) {
        await _cargarPedidos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Estado actualizado a "$nuevoEstatus"'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _mostrarDetallePedido(Order pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetallePedido(pedido),
    );
  }

  // ============================================================
  // MÉTODOS DE LOGOUT
  // ============================================================

  Future<void> _logout() async {
    if (_loggingOut) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Color(0xFF303030),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            style: TextStyle(color: Color(0xFF666666)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _loggingOut = true;
    });

    await _authService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // MÉTODOS DE CONSTRUCCIÓN DE WIDGETS
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(),
          _buildOrdersTab(),
          _buildProfile(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROGYMS',
            style: TextStyle(
              color: Color(0xFF303030),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          Text(
            'REPARTOS',
            style: TextStyle(
              color: PRIMARY_COLOR,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loggingOut ? null : _logout,
          tooltip: 'Cerrar sesión',
          icon: _loggingOut
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: PRIMARY_COLOR,
                  ),
                )
              : const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF666666),
                ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ============================================================
  // TAB INICIO
  // ============================================================

  Widget _buildHome() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _cargarPedidos,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcome(),
              const SizedBox(height: 24),
              _buildStatistics(),
              const SizedBox(height: 24),
              _buildFiltros(),
              const SizedBox(height: 12),
              _buildListaPedidos(true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PRIMARY_COLOR,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: PRIMARY_COLOR.withOpacity(0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hola',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
                Text(
                  widget.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Repartidor',
                    style: TextStyle(
                      color: PRIMARY_COLOR,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen',
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingPedidos)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else
          Row(
            children: [
              _buildStatCard(
                icon: Icons.pending_actions,
                value: _pedidosPendientes.toString(),
                label: 'Pendientes',
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _filtroActual = 'PENDIENTES';
                    _aplicarFiltro();
                    _currentIndex = 1;
                  });
                },
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                icon: Icons.local_shipping,
                value: _pedidosEnRuta.toString(),
                label: 'En ruta',
                color: Colors.indigo,
                onTap: () {
                  setState(() {
                    _filtroActual = 'EN RUTA';
                    _aplicarFiltro();
                    _currentIndex = 1;
                  });
                },
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                icon: Icons.check_circle,
                value: _pedidosEntregados.toString(),
                label: 'Entregados',
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _filtroActual = 'ENTREGADOS';
                    _aplicarFiltro();
                    _currentIndex = 1;
                  });
                },
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                icon: Icons.cancel,
                value: _pedidosCancelados.toString(),
                label: 'Cancelados',
                color: Colors.red,
                onTap: () {
                  setState(() {
                    _filtroActual = 'CANCELADOS';
                    _aplicarFiltro();
                    _currentIndex = 1;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE1E1E1),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF303030),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filtros.map((filtro) {
          final isSelected = _filtroActual == filtro;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                filtro,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF555555),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filtroActual = filtro;
                  _aplicarFiltro();
                });
              },
              backgroundColor: Colors.white,
              selectedColor: PRIMARY_COLOR,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? PRIMARY_COLOR : Colors.grey[300]!,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListaPedidos(bool isHome) {
    if (_isLoadingPedidos) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorPedidos != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              _errorPedidos!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargarPedidos,
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_pedidosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 50,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No hay pedidos ${_filtroActual.toLowerCase()}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final maxItems = isHome ? 5 : _pedidosFiltrados.length;
    final items = _pedidosFiltrados.take(maxItems).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pedido = items[index];
        return _buildOrderCard(pedido);
      },
    );
  }

  // ============================================================
  // TARJETA DE PEDIDO
  // ============================================================

  Widget _buildOrderCard(Order pedido) {
    return GestureDetector(
      onTap: () => _mostrarDetallePedido(pedido),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE1E1E1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pedido #${pedido.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF303030),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: pedido.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        pedido.statusIcon,
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        pedido.statusLabel,
                        style: TextStyle(
                          color: pedido.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Cliente
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 13, color: Color(0xFF666666)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    pedido.clienteNombre ?? 'Cliente no especificado',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Total y productos
            Row(
              children: [
                const Icon(Icons.attach_money,
                    size: 13, color: Color(0xFF666666)),
                const SizedBox(width: 5),
                Text(
                  '\$${pedido.total?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: PRIMARY_COLOR,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.shopping_bag,
                    size: 13, color: Color(0xFF666666)),
                const SizedBox(width: 5),
                Text(
                  '${pedido.cantidadProductos} items',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),

            // Dirección (resumida)
            if (pedido.hasAddress) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 13, color: Color(0xFF666666)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      pedido.direccion!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Botones de acción
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _getActionButtons(pedido),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getActionButtons(Order pedido) {
    final actions = pedido.getAvailableActions();

    if (actions.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Finalizado',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ];
    }

    return actions.map((action) {
      Color color;
      switch (action['color']) {
        case 'indigo':
          color = Colors.indigo;
          break;
        case 'green':
          color = Colors.green;
          break;
        case 'red':
          color = Colors.red;
          break;
        default:
          color = Colors.grey;
      }

      return ElevatedButton(
        onPressed: () {
          _cambiarEstadoPedido(pedido.id, action['action']!);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          action['label']!,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  // ============================================================
  // TAB PEDIDOS
  // ============================================================

  Widget _buildOrdersTab() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis pedidos',
                  style: TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isLoadingPedidos)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: PRIMARY_COLOR.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_pedidosFiltrados.length} pedidos',
                      style: const TextStyle(
                        color: PRIMARY_COLOR,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFiltros(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarPedidos,
              child: _buildListaPedidos(false),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETALLE DEL PEDIDO (MODAL)
  // ============================================================

  Widget _buildDetallePedido(Order pedido) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pedido #${pedido.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF303030),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: pedido.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            pedido.statusIcon,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pedido.statusLabel,
                            style: TextStyle(
                              color: pedido.statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, color: Color(0xFFEEEEEE)),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del cliente CON BOTÓN DE WHATSAPP
                      _buildDetalleSection(
                        icon: Icons.person,
                        title: 'Cliente',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pedido.clienteNombre ??
                                          'Cliente no especificado',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (pedido.clienteTelefono != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '📱 ${pedido.clienteTelefono}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                    if (pedido.clienteSucursal != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '🏢 Sucursal: ${pedido.clienteSucursal}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Botón de WhatsApp
                              if (pedido.clienteTelefono != null &&
                                  pedido.clienteTelefono!.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.green[200]!,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () => _abrirWhatsApp(
                                      pedido.clienteTelefono!,
                                      pedido.clienteNombre ?? 'Cliente',
                                    ),
                                    icon: Image.asset(
                                      'assets/whatsapp.png',
                                      width: 28,
                                      height: 28,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.message,
                                          color: Colors.green,
                                          size: 28,
                                        );
                                      },
                                    ),
                                    tooltip: 'Enviar WhatsApp',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Dirección con botón de mapa
                      if (pedido.hasAddress)
                        _buildDetalleSection(
                          icon: Icons.location_on,
                          title: 'Dirección',
                          children: [
                            Text(
                              pedido.direccion!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF444444),
                              ),
                            ),
                            if (pedido.hasLocation) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '📍 ${pedido.latitud}, ${pedido.longitud}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF888888),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _abrirMapa(
                                      pedido.latitud!,
                                      pedido.longitud!,
                                      pedido.direccion!,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: PRIMARY_COLOR,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.map, size: 14),
                                    label: const Text(
                                      'Abrir',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Información del pedido
                      _buildDetalleSection(
                        icon: Icons.receipt,
                        title: 'Información',
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              Text(
                                '\$${pedido.total?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: PRIMARY_COLOR,
                                ),
                              ),
                            ],
                          ),
                          if (pedido.metodoPago != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pago:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                Text(
                                  pedido.metodoPago!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (pedido.fecha != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Fecha:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                Text(
                                  pedido.fecha!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (pedido.repartidorNombre != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Repartidor:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                Text(
                                  pedido.repartidorNombre!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Productos (versión compacta)
                      if (pedido.productos != null &&
                          pedido.productos!.isNotEmpty)
                        _buildDetalleSection(
                          icon: Icons.shopping_bag,
                          title: 'Productos (${pedido.cantidadProductos})',
                          children: [
                            // Encabezado compacto
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 6),
                              decoration: BoxDecoration(
                                color: PRIMARY_COLOR.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Producto',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: PRIMARY_COLOR,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Cant',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: PRIMARY_COLOR,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Subtotal',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: PRIMARY_COLOR,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Lista de productos compacta
                            ...pedido.productosFormateados.map((producto) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[100]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            producto['nombre'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF444444),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'x${producto['cantidad']}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '\$${producto['subtotal'].toStringAsFixed(2)}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: PRIMARY_COLOR,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Código y sucursal en una línea pequeña
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            'Cód: ${producto['codigo']}',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            producto['sucursal'],
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            // Total
                            const Divider(height: 12, color: Color(0xFFEEEEEE)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                                Text(
                                  '\$${pedido.totalProductos.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: PRIMARY_COLOR,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Nota
                      if (pedido.nota != null && pedido.nota!.isNotEmpty)
                        _buildDetalleSection(
                          icon: Icons.note,
                          title: 'Nota',
                          children: [
                            Text(
                              pedido.nota!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Botones de acción
                      if (pedido.getAvailableActions().isNotEmpty) ...[
                        const Text(
                          'Acciones:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF303030),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pedido.getAvailableActions().map((action) {
                            Color color;
                            switch (action['color']) {
                              case 'indigo':
                                color = Colors.indigo;
                                break;
                              case 'green':
                                color = Colors.green;
                                break;
                              case 'red':
                                color = Colors.red;
                                break;
                              default:
                                color = Colors.grey;
                            }

                            return ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _cambiarEstadoPedido(
                                    pedido.id, action['action']!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                action['label']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Este pedido ya está finalizado',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetalleSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: PRIMARY_COLOR),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF303030),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // TAB PERFIL
  // ============================================================

  Widget _buildProfile() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PRIMARY_COLOR,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: PRIMARY_COLOR.withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF303030),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.user.email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.user.email,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: PRIMARY_COLOR.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Repartidor',
                style: TextStyle(
                  color: PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tarjeta de estadísticas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE1E1E1),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, color: PRIMARY_COLOR, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF303030),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat('Pendientes',
                          _pedidosPendientes.toString(), Colors.orange),
                      _buildProfileStat(
                          'En ruta', _pedidosEnRuta.toString(), Colors.indigo),
                      _buildProfileStat('Entregados',
                          _pedidosEntregados.toString(), Colors.green),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat('Cancelados',
                          _pedidosCancelados.toString(), Colors.red),
                      _buildProfileStat(
                          'Total', _pedidosTotales.toString(), PRIMARY_COLOR),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _loggingOut ? null : _logout,
                icon: _loggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout, size: 18),
                label: Text(
                  _loggingOut ? 'CERRANDO...' : 'CERRAR SESIÓN',
                  style: const TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION BAR
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 6,
      indicatorColor: PRIMARY_COLOR.withOpacity(0.10),
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: Color(0xFF888888),
          ),
          selectedIcon: Icon(
            Icons.home,
            color: PRIMARY_COLOR,
          ),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF888888),
          ),
          selectedIcon: Icon(
            Icons.inventory_2,
            color: PRIMARY_COLOR,
          ),
          label: 'Pedidos',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
            color: Color(0xFF888888),
          ),
          selectedIcon: Icon(
            Icons.person,
            color: PRIMARY_COLOR,
          ),
          label: 'Perfil',
        ),
      ],
    );
  }
}
