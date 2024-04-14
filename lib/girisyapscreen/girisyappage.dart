import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skolyozapp/kayitolscreen/kayitolpage.dart';
import 'package:skolyozapp/navbar/navbar.dart';
import 'package:skolyozapp/sifresifirlamascreen/sifresifirlamapage.dart';

class GirisYapPage extends StatefulWidget {
  @override
  State<GirisYapPage> createState() => _GirisYapPageState();
}

class _GirisYapPageState extends State<GirisYapPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _email, _password;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscureText = true;

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
                              width: screenSize.width * 0.3,
                              height: screenSize.height * 0.3))
                      : Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Lottie.asset(
                                'assets/animations/loginanimasyon.json',
                                height: screenSize.height * 0.25,
                              ),
                              SizedBox(
                                height: screenSize.height * 0.02,
                              ),
                              Text(
                                'Giriş Yap',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: screenSize.height * 0.01,
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
                              SizedBox(height: screenSize.height * 0.01),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Şifre',
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscureText,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Şifre giriniz';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _password = value!,
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value!;
                                      });
                                    },
                                  ),
                                  Text('Beni Hatırla'),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await _auth.signInWithEmailAndPassword(
                                        email: _email,
                                        password: _password,
                                      );
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      if (_rememberMe) {
                                        prefs.setString('email', _email);
                                        prefs.setString('password', _password);
                                      } else {
                                        prefs.remove('email');
                                        prefs.remove('password');
                                      }

                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NavBarPage()));
                                    } catch (e) {
                                      print("Giriş hatası: $e");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("Hata: $e"),
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                                child: Text('Giriş Yap'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              screenSize.width * 0.01))),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SifremiUnuttumPage()),
                                  );
                                },
                                child: Text('Şifreni mi unuttun?',
                                    style: TextStyle(
                                        color: Colors.red)),
                              ),
                              Divider(
                                height: screenSize.height * 0.002,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => KayitOlPage()),
                                  );
                                },
                                child: Text('Hesabın Yok mu? Kayıt Ol',
                                    style: TextStyle(
                                        color:Colors.red)),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
