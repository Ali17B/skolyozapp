import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IcerikDetayPage extends StatefulWidget {
  final String documentId;

  const IcerikDetayPage({Key? key, required this.documentId}) : super(key: key);

  @override
  State<IcerikDetayPage> createState() => _IcerikDetayPageState();
}

class _IcerikDetayPageState extends State<IcerikDetayPage> {
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('bloglartable');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          toolbarHeight: 0,
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: collectionRef.doc(widget.documentId).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return Center(child: Text('İçerik bulunamadı.'));
              }

              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                  child: Column(children: [
                Stack(
                  children: [
                    Image.network(
                      data['gorsel'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 230,
                    ),
                    Container(
                      height: 231,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Color.fromARGB(0, 0, 0, 0), Colors.black38],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 12,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                            ),
                            Text(
                              data['baslik'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800),
                            ),
                          ]),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 26, right: 26, top: 25, bottom: 20),
                        child: Text(
                          data['yazi'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey.shade700,
                              fontWeight: FontWeight.w100),
                        ),
                      ),
                      ...List.generate(5, (index) {
                        String altbaslikKey = 'altbaslik${index + 1}';
                        String yaziKey = 'yazi${index + 2}';
                        if (data[altbaslikKey] != null &&
                            data[yaziKey] != null) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 26, right: 26, top: 15, bottom: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    data[altbaslikKey],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blueGrey.shade800),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  data[yaziKey],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueGrey.shade700,
                                      fontWeight: FontWeight.w100),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container();
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ekleyen: Dr. Ali',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.blueGrey.shade700,
                              )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26.0, vertical: 20),
                        child: Text(
                          "Etiketler: ${data['tags'] is String ? (data['tags'] as String).split(', ').join(', ') : 'Etiket Yok'}",
                          style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey.shade800),
                        ),
                      ),
                    ],
                  ),
                ))
              ]));
            }));
  }
}
