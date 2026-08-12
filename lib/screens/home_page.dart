import 'package:flutter/material.dart';
import '../constant.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(),
          _buildOrders(),
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

  Widget _buildHome() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcome(),
            const SizedBox(height: 30),
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: PRIMARY_COLOR,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: PRIMARY_COLOR.withOpacity(0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hola',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.user.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                    ),
                  ),
                ],
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
          'Resumen de hoy',
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildStatisticCard(
                icon: Icons.inventory_2_outlined,
                value: '8',
                label: 'Pendientes',
                color: WARNING_COLOR,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatisticCard(
                icon: Icons.local_shipping_outlined,
                value: '3',
                label: 'En ruta',
                color: PRIMARY_COLOR,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatisticCard(
                icon: Icons.check_circle_outline,
                value: '12',
                label: 'Entregados',
                color: SUCCESS_COLOR,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF303030),
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrders() {
    return const SafeArea(
      child: Center(
        child: Text(
          'Mis pedidos',
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: PRIMARY_COLOR,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: PRIMARY_COLOR.withOpacity(0.20),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.user.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF303030),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.user.email.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loggingOut ? null : _logout,
                  icon: _loggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(
                    _loggingOut ? 'CERRANDO SESIÓN...' : 'CERRAR SESIÓN',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 8,
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
