// ----- STRINGS ------
import 'package:flutter/material.dart';

//const  = 'https://seges.com.mx/api';
const baseURL2 = 'https://seges.com.mx/pedidos';
const baseURL = 'http://192.168.0.116:8000/api';

const loginURL = baseURL + '/login';
const dropURL = baseURL + '/drop';
const registerURL = baseURL + '/register';
const logoutURL = baseURL + '/logout';
const userURL = baseURL + '/user';
const postsURL = baseURL + '/posts';
const commentsURL = baseURL + '/comments';
const addressURL = baseURL + '/address';
const ordersURL = baseURL + '/getorders';
const setnotefromdelivery = baseURL2 + '/aux1';
const getnotestodelivery = baseURL2 + '/vernota';
const setcurentposition = baseURL2 + '/aux2';
const deliverysURL = baseURL + '/aux1';
const startProgressURL = baseURL + '/aux2';
const endProgressURL = baseURL + '/aux3';
const setOrder = baseURL + '/setorders';
const addressByCpURL = baseURL + '/addressbycp';
const setaddressByCpURL = baseURL + '/insertupdateaddress';
const headers = {'Accept': 'application/json'};
const MAP_API = "AIzaSyCI9KYYmGxX3_PpRTjvzimwhlfRmemqH7g";
final Color PRYMARY_COLOR = Color.fromRGBO(250, 120, 0, 1);
final Color SECONDARY_COLOR = Color.fromRGBO(0, 0, 0, 1);
final Color THYRD_COLOR = Color.fromRGBO(0, 0, 0, 1);
final List<String> beersList = [
  'Bud Light',
  'Corona Extra',
  'Corona Light',
  'Heineken',
  'Indio',
  'Modelo Especial',
  'Tecate Ambar',
  'Tecate Light',
  'Tecate Roja',
  'Tecate Titanium',
  'Victoria',
  'XX Lagger',
  'XX Ambar',
];
final List<String> frostyList = [
  'Ajonjoli',
  'Bubble Gum',
  'Burbu Soda',
  'Chapulín',
  'Lucas Mango',
  'Pelon Pelo Rico',
  'Pepino',
  'Pica Fresa',
  'PintaAzul',
  'Pulparindo',
  'Rockaleta',
  'Sin escarchado',
  'Super Rebanadas',
  'Tarrito',
  'Truena Pop',
  'Tupsi Pop'
];
final List<String> skewerList = [
  'Gomitas Enchiladas',
  'Tamarindo',
  'Sin brocheta',
];
final List<String> snackList = [
  'Cacahuates Enchilados',
  'Cerezas Picantes',
  'Cueritos',
  'Gomitas Enchiladas',
  'Jicama Pepino Zanahoria',
  'Sin botana',
];
final List<String> redbullList = [
  'Red Bull Energy',
  'Red Bull Sugar Free',
  'Red Bull Tropical',
];
final List<String> icecreamList = [
  'Tamarindo',
  'Mango',
];
final List<String> mezcalList = [
  '400 Conejos',
  '1000 Diablos',
  'Alacrán',
  'Union',
];
final List<String> clamatoList = [
  'Clamato Natural',
  'Clamato Preparado',
];
final List<String> flavorsList = [
  'Blue Berry',
  'Coco',
  'Durazno',
  'Frambuesa',
  'Fresa',
  'Frutos Rojos',
  'Mandarina',
  'Mango',
  'Manzana Verde',
  'Maracuya',
  'Pepino-Morita',
  'Piña Chamoy',
  'Piña Colada',
  'Tamarindo',
  'Uva',
];
// ----- Errors -----
const serverError = 'Error en el servidor';
const unauthorized = 'no autorizado';
const somethingWentWrong = 'Algo salio mal intente de nuevo';

// --- input decoration
InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.black)));
}

// button

TextButton kTextButton(String label, Function onPressed) {
  return TextButton(
    child: Text(
      label,
      style: TextStyle(color: Colors.white),
    ),
    style: ButtonStyle(
        backgroundColor:
            MaterialStateColor.resolveWith((states) => PRYMARY_COLOR),
        padding: MaterialStateProperty.resolveWith(
            (states) => EdgeInsets.symmetric(vertical: 10))),
    onPressed: () => onPressed(),
  );
}

// loginRegisterHint
Row kLoginRegisterHint(String text, String label, Function onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text,
          style: TextStyle(
            fontFamily: 'BebasNeue-Regular',
            fontSize: 14,
          )),
      GestureDetector(
          child:
              Text(label, style: TextStyle(color: PRYMARY_COLOR, fontSize: 12)),
          onTap: () => onTap())
    ],
  );
}

// likes and comment btn

Expanded kLikeAndComment(
    int value, IconData icon, Color color, Function onTap) {
  return Expanded(
    child: Material(
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              SizedBox(width: 4),
              Text('$value')
            ],
          ),
        ),
      ),
    ),
  );
}
