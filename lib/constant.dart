import 'package:flutter/material.dart';

// ============================================================
// PROGYMS REPARTOS
// Configuración general de la aplicación
// ============================================================

// ============================================================
// API
// ============================================================

const baseURL2 = 'https://seges.com.mx/pedidos';
const baseURL = 'http://193.186.4.212:8000/api';

const loginURL = '$baseURL/login';
const dropURL = '$baseURL/drop';
const registerURL = '$baseURL/register';
const logoutURL = '$baseURL/logout';
const userURL = '$baseURL/user';
const postsURL = '$baseURL/posts';
const commentsURL = '$baseURL/comments';
const addressURL = '$baseURL/address';
const ordersURL = '$baseURL/getorders';

const setnotefromdelivery = '$baseURL2/aux1';
const getnotestodelivery = '$baseURL2/vernota';
const setcurentposition = '$baseURL2/aux2';

const deliverysURL = '$baseURL/aux1';
const startProgressURL = '$baseURL/aux2';
const endProgressURL = '$baseURL/aux3';
const setOrder = '$baseURL/setorders';

const addressByCpURL = '$baseURL/addressbycp';
const setaddressByCpURL = '$baseURL/insertupdateaddress';

const headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
};

const MAP_API = 'AIzaSyCI9KYYmGxX3_PpRTjvzimwhlfRmemqH7g';

// ============================================================
// COLORES - PROGYMS REPARTOS
// ============================================================

// Rojo principal de la aplicación
const Color PRIMARY_COLOR = Color(0xFFE53935);

// Rojo oscuro
const Color PRIMARY_DARK_COLOR = Color(0xFFC62828);

// Rojo profundo
const Color PRIMARY_DEEP_COLOR = Color(0xFF8E0000);

// Fondo principal
const Color BACKGROUND_COLOR = Color(0xFF101010);

// Fondo secundario
const Color SURFACE_COLOR = Color(0xFF181818);

// Fondo de tarjetas
const Color CARD_COLOR = Color(0xFF242424);

// Gris oscuro
const Color DARK_GRAY_COLOR = Color(0xFF303030);

// Bordes
const Color BORDER_COLOR = Color(0xFF3D3D3D);

// Gris
const Color GRAY_COLOR = Color(0xFF757575);

// Gris claro
const Color LIGHT_GRAY_COLOR = Color(0xFFBDBDBD);

// Texto principal
const Color TEXT_PRIMARY_COLOR = Color(0xFFFFFFFF);

// Texto secundario
const Color TEXT_SECONDARY_COLOR = Color(0xFF9E9E9E);

// Blanco
const Color WHITE_COLOR = Color(0xFFFFFFFF);

// Negro
const Color BLACK_COLOR = Color(0xFF000000);

// Éxito
const Color SUCCESS_COLOR = Color(0xFF43A047);

// Advertencia
const Color WARNING_COLOR = Color(0xFFFFB300);

// Error
const Color ERROR_COLOR = Color(0xFFD32F2F);

// ============================================================
// COLORES HEREDADOS
// Se mantienen para evitar errores en código existente
// ============================================================

final Color PRYMARY_COLOR = PRIMARY_COLOR;
final Color SECONDARY_COLOR = BLACK_COLOR;
final Color THYRD_COLOR = BLACK_COLOR;

// ============================================================
// ERRORES Y MENSAJES
// ============================================================

const serverError = 'Error en el servidor';
const unauthorized = 'No autorizado';
const somethingWentWrong = 'Algo salió mal, intente de nuevo';

// ============================================================
// INPUTS
// ============================================================

InputDecoration kInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: TEXT_SECONDARY_COLOR,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    filled: true,
    fillColor: CARD_COLOR,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        width: 1,
        color: BORDER_COLOR,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        width: 1.5,
        color: PRIMARY_COLOR,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

// ============================================================
// BOTÓN PRINCIPAL
// ============================================================

TextButton kTextButton(
  String label,
  Function onPressed,
) {
  return TextButton(
    onPressed: () => onPressed(),
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => PRIMARY_COLOR,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => WHITE_COLOR,
      ),
      padding: WidgetStateProperty.resolveWith(
        (states) => const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
      ),
      shape: WidgetStateProperty.resolveWith(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: WHITE_COLOR,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// ============================================================
// LOGIN / REGISTER HINT
// ============================================================

Row kLoginRegisterHint(
  String text,
  String label,
  Function onTap,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: TEXT_SECONDARY_COLOR,
        ),
      ),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: () => onTap(),
        child: Text(
          label,
          style: const TextStyle(
            color: PRIMARY_COLOR,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

// ============================================================
// LIKES Y COMENTARIOS
// ============================================================

Expanded kLikeAndComment(
  int value,
  IconData icon,
  Color color,
  Function onTap,
) {
  return Expanded(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '$value',
                style: const TextStyle(
                  color: TEXT_PRIMARY_COLOR,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
