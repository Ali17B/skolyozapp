import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skolyozapp/girisyapscreen/girisyappage.dart';

class Screen1 extends StatefulWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GirisYapPage()),
                  );
                },
                child: Text('Geç',
                    style:
                        TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  width: 320,
                  height: 350,
                  child: Lottie.asset('assets/animations/iskelet.json'),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    "Doğru Duruş App'e Hoş Geldiniz",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Doğru Duruş Takip Uygulamasına Hoş Geldiniz! Duruşunuzun günlük izlenmesi artık çok daha kolay. Kişiselleştirilmiş takip çözümlerimizle duruşunuzu düzenleyin, sağlığınızı koruyun.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color.fromARGB(239, 255, 255, 255)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
