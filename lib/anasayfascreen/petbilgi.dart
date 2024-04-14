import 'package:flutter/material.dart';

class PetDetails extends StatefulWidget {
  final Map<String, dynamic> petInfo;

  const PetDetails({Key? key, required this.petInfo}) : super(key: key);

  @override
  _PetDetailsState createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  String _calculateAge(String birthDate) {
    return "Yaş hesaplanacak";
  }

  @override
  Widget build(BuildContext context) {
    var petInfo = widget.petInfo;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Image.asset(
              'assets/images/yas.png',
              cacheHeight: 35,
              cacheWidth: 35,
            ),
            SizedBox(height: 5),
            Text(
              _calculateAge(petInfo['dogum_tarihi']),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          children: [
            Image.asset(
              'assets/images/weight.png',
              cacheHeight: 35,
              cacheWidth: 35,
            ),
            SizedBox(height: 5),
            Text(
              '${petInfo['kilo']} Gr',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          children: [
            Image.asset(
              'assets/images/irk.png',
              cacheHeight: 35,
              cacheWidth: 35,
            ),
            SizedBox(height: 5),
            Text(
              petInfo['irk'],
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          children: [
            Image.asset(
              'assets/images/gender.png',
              cacheHeight: 35,
              cacheWidth: 35,
            ),
            SizedBox(height: 5),
            Text(
              petInfo['cinsiyet'],
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
