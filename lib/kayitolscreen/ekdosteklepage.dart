import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skolyozapp/navbar/navbar.dart';

class EkHayvanEklePage extends StatefulWidget {
  const EkHayvanEklePage({super.key});

  @override
  State<EkHayvanEklePage> createState() => _EkHayvanEklePageState();
}

class _EkHayvanEklePageState extends State<EkHayvanEklePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _isim;
  String? _selectedGender;
  bool showError = false;
  String? _kilo;
  File? _imageFile;
  String? _selectedBreed;
  final picker = ImagePicker();
  TextEditingController _dateController = TextEditingController();

  String? _selectedPetType;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = path.basename(imageFile.path);
    Reference ref =
        FirebaseStorage.instance.ref().child('pets_images/$fileName');
    UploadTask uploadTask = ref.putFile(imageFile);
    await uploadTask.whenComplete(() {});
    return await ref.getDownloadURL();
  }

  Future<void> uploadImageAndSaveData() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      _formKey.currentState!.save();

      String imageUrl = await uploadImage(_imageFile!);

      User? currentUser = _auth.currentUser;

      final DocumentReference userDoc = FirebaseFirestore.instance
          .collection('kullanicilartable')
          .doc(currentUser!.uid);

      Map<String, dynamic> newPet = {
        'imageUrl': imageUrl,
        'name': _isim,
        'dogum_tarihi': _dateController.text,
        'cinsiyet': _selectedGender,
        'tur': _selectedPetType,
        'irk': _selectedBreed,
        'kilo': _kilo,
      };

      DocumentSnapshot userData = await userDoc.get();

      if (userData['pets2'] != null) {
        await userDoc.update({
          'pets3': FieldValue.arrayUnion([newPet]),
        });
      } else {
        await userDoc.update({
          'pets2': FieldValue.arrayUnion([newPet]),
        });
      }

      setState(() {
        showError = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NavBarPage(),
        ),
      );
    } else {
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.amber],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 05,
              color: Colors.white10,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.only(top: 40, bottom: 40),
                width: MediaQuery.of(context).size.width * 0.85,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 20),
                        Text('Diğer dostunu eklemek için bilgileri doldur. ',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        SizedBox(height: 26),
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  InkWell(
                                    onTap: _pickImage,
                                    child: _imageFile == null
                                        ? Center(
                                            child: Icon(
                                              Icons.add_photo_alternate_rounded,
                                              size: 50,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              _imageFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  ),
                                  if (_imageFile != null)
                                    Positioned(
                                      right: -5,
                                      top: -5,
                                      child: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red.shade600),
                                        onPressed: () {
                                          setState(() {
                                            _imageFile = null;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            if (_imageFile == null && showError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Lütfen bir görsel yükleyin',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Adı', border: OutlineInputBorder()),
                          validator: (value) {
                            if (value!.isEmpty) return 'Ad kısmını doldurunuz';
                            return null;
                          },
                          onSaved: (value) => _isim = value!,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Doğum Tarihi',
                          ),
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null && date != DateTime.now()) {
                              _dateController.text =
                                  "${date.toLocal()}".split(' ')[0];
                            }
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Lütfen bir doğum tarihi seçin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Kilo (Gram)',
                              suffixText: 'Gram',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _kilo = value!,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Lütfen kiloyu girin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField2<String>(
                          items: ['Kedi', 'Köpek'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(labelText: 'Türü seçin'),
                          onChanged: (value) {
                            setState(() {
                              _selectedPetType = value;
                              _selectedBreed = null;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir tür seçin';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField2<String>(
                          items: ['Dişi', 'Erkek'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(labelText: 'Cinsiyet'),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir cinsiyet seçin';
                            }
                            return null;
                          },
                        ),
                        if (_selectedGender != null)
                          DropdownButtonFormField2<String>(
                            items: (_selectedPetType == 'Kedi'
                                    ? [
                                        'Abyssinian',
                                        'Ankara Kedisi',
                                        'Bengal',
                                        'British Shorthair',
                                        'Maine Coon',
                                        'Mısır Mau',
                                        'Persian',
                                        'Ragdoll',
                                        'Rus Mavisi',
                                        'Scottish Fold',
                                        'Siamese',
                                        'Sibirya Kedisi',
                                        'Singapura',
                                        'Somali',
                                        'Sphynx',
                                        'Türk Van Kedisi',
                                        'Türk Angora',
                                        'Tonkinese',
                                        'Tiffany',
                                        'Thai'
                                      ]
                                    : [
                                        'Akita',
                                        'Alman Çoban Köpeği',
                                        'Beagle',
                                        'Boxer',
                                        'Bulldog',
                                        'Chihuahua',
                                        'Dalmatian',
                                        'Doberman Pinscher',
                                        'Golden Retriever',
                                        'Labrador Retriever',
                                        'Maltese',
                                        'Pitbull',
                                        'Pomeranian',
                                        'Rottweiler',
                                        'Samoyed',
                                        'Schnauzer',
                                        'Shih Tzu',
                                        'Siberian Husky',
                                        'Yorkshire Terrier',
                                        'Vizsla'
                                      ])
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(labelText: 'Irk seçin'),
                            onChanged: (value) {
                              setState(() {
                                _selectedBreed = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir ırk seçin';
                              }
                              return null;
                            },
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: uploadImageAndSaveData,
                          child: Text('Ekleme İşlemini Tamamla'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.amber.shade600),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
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
            left: MediaQuery.of(context).size.width * 0.001,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
