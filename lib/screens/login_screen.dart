// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _showCredentialsHelp = false;

  @override
  void initState() {
    super.initState();
    // Pre-cargar las credenciales para facilitar pruebas
    _emailController.text = 'clemente.zarraga@progyms.com';
    _passwordController.text = 'Progyms123\$';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF5F5),
                Color(0xFFFFE8E8),
                Color(0xFFFFD4D4),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header con logo y título
                    _buildHeader(),

                    const SizedBox(height: 30),

                    // Ayuda visual de credenciales (opcional, solo para pruebas)
                    _buildCredentialsHelper(),

                    const SizedBox(height: 20),

                    // Campos de texto
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),

                    const SizedBox(height: 12),

                    // Recordarme y olvidé contraseña
                    _buildRememberAndForgot(),

                    const SizedBox(height: 28),

                    // Botón de login
                    _buildLoginButton(authProvider),

                    const SizedBox(height: 16),

                    // Mensaje de error
                    _buildErrorMessage(authProvider),

                    const SizedBox(height: 30),

                    // Separador
                    _buildDivider(),

                    const SizedBox(height: 20),

                    // Link de registro
                    _buildRegisterLink(),

                    const SizedBox(height: 20),

                    // Botón de ayuda (solo para pruebas)
                    _buildTestHelper(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== BUILD HEADER ====================
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          // Logo circular con icono de entrega
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCC0000),
                  Color(0xFF8B0000),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCC0000).withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delivery_dining,
                  size: 45,
                  color: Colors.white,
                ),
                SizedBox(height: 4),
                Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'PROGYMS EXPRESS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B0000),
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFCC0000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🚚 Repartidor',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFCC0000),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Inicia sesión para gestionar tus entregas',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CREDENTIALS HELPER ====================
  Widget _buildCredentialsHelper() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCC0000).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCC0000).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFCC0000).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFFCC0000),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Credenciales de acceso',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B0000),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'clemente.zarraga@progyms.com',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showCredentialsHelp = !_showCredentialsHelp;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFCC0000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Mostrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD EMAIL FIELD ====================
  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      label: 'Correo Electrónico',
      hintText: 'repartidor@progyms.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu correo electrónico';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
      onChanged: (value) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.clearError();
      },
    );
  }

  // ==================== BUILD PASSWORD FIELD ====================
  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _passwordController,
      label: 'Contraseña',
      hintText: 'Ingresa tu contraseña',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFFCC0000),
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
      onChanged: (value) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.clearError();
      },
    );
  }

  // ==================== BUILD REMEMBER & FORGOT ====================
  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFFCC0000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Recordarme',
              style: TextStyle(
                color: Color(0xFF8B0000),
                fontSize: 14,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _showForgotPasswordDialog,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFCC0000),
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== BUILD LOGIN BUTTON ====================
// lib/screens/login_screen.dart
// ... (el resto del código igual, solo actualiza el método _buildLoginButton)

  Widget _buildLoginButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  FocusScope.of(context).unfocus();

                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  // Mostrar diálogo de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final success = await authProvider.login(email, password);

                  // Cerrar diálogo de carga
                  Navigator.pop(context);

                  if (success && mounted) {
                    _showSuccessDialog();
                  } else if (mounted) {
                    // Mostrar el error del provider
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          authProvider.errorMessage ??
                              'Error al iniciar sesión',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFFCC0000),
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCC0000),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: const Color(0xFFCC0000).withOpacity(0.4),
          disabledBackgroundColor: const Color(0xFFCC0000).withOpacity(0.5),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: authProvider.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Verificando credenciales...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_rounded,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==================== BUILD ERROR MESSAGE ====================
  Widget _buildErrorMessage(AuthProvider authProvider) {
    if (authProvider.errorMessage == null) {
      return const SizedBox.shrink();
    }

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFCC0000).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFCC0000),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                authProvider.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF8B0000),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                authProvider.clearError();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFCC0000).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF8B0000),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD DIVIDER ====================
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: const Color(0xFFCC0000).withOpacity(0.2),
            thickness: 1.2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '¿NUEVO REPARTIDOR?',
            style: TextStyle(
              color: const Color(0xFFCC0000).withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: const Color(0xFFCC0000).withOpacity(0.2),
            thickness: 1.2,
          ),
        ),
      ],
    );
  }

  // ==================== BUILD REGISTER LINK ====================
  Widget _buildRegisterLink() {
    return Center(
      child: InkWell(
        onTap: () {
          _showRegisterInfo();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
              ),
              children: [
                const TextSpan(text: '¿No tienes cuenta de repartidor? '),
                TextSpan(
                  text: 'Contáctanos',
                  style: TextStyle(
                    color: const Color(0xFFCC0000),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFFCC0000),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== TEST HELPER ====================
  Widget _buildTestHelper() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Datos de prueba (solo desarrollo)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildTestChip(
                'clemente.zarraga@progyms.com',
                isEmail: true,
              ),
              const SizedBox(width: 8),
              _buildTestChip(
                r'Progyms123$',
                isEmail: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestChip(String text, {bool isEmail = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEmail
            ? const Color(0xFFCC0000).withOpacity(0.1)
            : const Color(0xFFFFB3B3).withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isEmail
              ? const Color(0xFFCC0000).withOpacity(0.2)
              : const Color(0xFFCC0000).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmail ? Icons.email_outlined : Icons.lock_outline,
            size: 12,
            color: const Color(0xFFCC0000),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF8B0000),
              fontWeight: FontWeight.w500,
              fontFamily: isEmail ? null : 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DIÁLOGOS ====================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFCC0000),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                color: Color(0xFF8B0000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Has iniciado sesión correctamente.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFCC0000).withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Color(0xFFCC0000),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Repartidor: ${Provider.of<AuthProvider>(context, listen: false).userName ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A0000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Color(0xFFCC0000),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Provider.of<AuthProvider>(context, listen: false)
                                .userEmail ??
                            '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFCC0000),
            ),
            child: const Text(
              'IR AL PANEL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(
            color: Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa tu correo electrónico y te enviaremos las instrucciones para restablecer tu contraseña.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'clemente.zarraga@progyms.com',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFCC0000),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFFCC0000).withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFCC0000),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      '📧 Se enviaron las instrucciones a tu correo',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: const Color(0xFFCC0000),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showRegisterInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '¿Quieres ser repartidor?',
          style: TextStyle(
            color: Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para convertirte en repartidor de Progyms Express, contáctanos a través de:',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
                Icons.email_outlined, 'reclutamiento@progyms.com'),
            const SizedBox(height: 10),
            _buildContactCard(Icons.phone_outlined, '+52 55 1234 5678'),
            const SizedBox(height: 10),
            _buildContactCard(Icons.chat_outlined, 'WhatsApp: 55 9876 5432'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Color(0xFFCC0000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFCC0000).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFCC0000),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A0000),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
