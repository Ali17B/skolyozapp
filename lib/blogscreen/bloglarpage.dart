import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skolyozapp/blogscreen/blogdetaypage.dart';

class BloglarPage extends StatefulWidget {
  const BloglarPage({Key? key}) : super(key: key);

  @override
  State<BloglarPage> createState() => _BloglarPageState();
}

class _BloglarPageState extends State<BloglarPage> {
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('bloglartable');
  final CollectionReference tagsRef =
      FirebaseFirestore.instance.collection('tags');
  String? selectedTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Skolyoz App Blog',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: Column(children: [
          FutureBuilder<DocumentSnapshot>(
            future: tagsRef.doc('T3RpExqP35Uf5rB0MRyw').get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              Map<String, dynamic> tags =
                  snapshot.data!.data() as Map<String, dynamic>;

              return Container(
                height: 55,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Tümü', ...tags.values].map((tag) {
                    bool isSelected = selectedTag == tag ||
                        (selectedTag == null && tag == 'Tümü');
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTag = tag == 'Tümü' ? null : tag;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          color: isSelected
                              ? Colors.blue
                              : Colors
                                  .white, //seçilen kategori mavi diğerleri turuncu
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 7.0),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: collectionRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    List<String> tagsList =
                        (data['tags'] as String).split(', ');

                    if (selectedTag != null && !tagsList.contains(selectedTag))
                      return Container();

                    return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IcerikDetayPage(
                                      documentId: document
                                          .id), //document.id ile gönderinin idsini alıyoruz
                                ),
                              );
                            },
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15)),
                                        child: Image.network(data['gorsel']),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 13,
                                          top: 7,
                                          left: 15,
                                          bottom: 7),
                                      child: Text(
                                        data['baslik'],
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['yazi'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade900,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 3, bottom: 10),
                                            child: Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .remove_red_eye_rounded,
                                                    color: Colors.grey.shade700,
                                                    size: 16),
                                                SizedBox(width: 5),
                                                Text(
                                                  "${data['goruntulenme']}",
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 12),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                IcerikDetayPage(
                                                                    documentId:
                                                                        document
                                                                            .id),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                          "Devamını Oku...",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blue)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            )));
                  }).toList(),
                );
              },
            ),
          )
        ]));
  }
}
