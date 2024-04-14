import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SifremiUnuttumPage extends StatefulWidget {
  @override
  _SifremiUnuttumPageState createState() => _SifremiUnuttumPageState();
}

class _SifremiUnuttumPageState extends State<SifremiUnuttumPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _email;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: screenSize.height * 0.5,
              color: Colors.blue,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenSize.height * 0.5,
              color: Colors.white10,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: screenSize.width * 0.85,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _isLoading
                      ? Center(
                          child: Lottie.asset(
                              'assets/animations/loading_animation.json',
                              width: 100,
                              height: 100),
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Şifreni mi Unuttun?',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: screenSize.height * 0.02,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Email giriniz';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _email = value!,
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await _auth.sendPasswordResetEmail(
                                          email: _email);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Başarılı!'),
                                            content: Text(
                                                'Şifre sıfırlama bağlantısı gönderildi.'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Tamam'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      String hataMesaji;
                                      if (e.code == 'user-not-found') {
                                        hataMesaji =
                                            'Bu e-posta adresi ile kayıtlı bir kullanıcı bulunamadı.';
                                      } else if (e.code == 'invalid-email') {
                                        hataMesaji =
                                            'Geçersiz bir e-posta adresi girdiniz.';
                                      } else {
                                        hataMesaji = 'Bir hata oluştu: $e';
                                      }

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Hata!'),
                                            content: Text(hataMesaji),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Tamam'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                                child: Text('Sıfırlama E-postası Gönder'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              screenSize.width * 0.01))),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.005,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
