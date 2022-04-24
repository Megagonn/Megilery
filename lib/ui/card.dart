import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PexelCard extends StatefulWidget {
  const PexelCard({Key? key}) : super(key: key);

  @override
  _PexelCardState createState() => _PexelCardState();
}

class _PexelCardState extends State<PexelCard> {
  bool myFavourite = false;
  @override
  Widget build(BuildContext context) {
    dynamic pexel = ModalRoute.of(context)!.settings.arguments;
    // print(pexel.alt);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: Text(
          pexel.alt.toString().toUpperCase(),
          overflow: TextOverflow.ellipsis,
        )),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              child: Image.network(pexel.portrait),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height - 100,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade100.withAlpha(100),
                        child: IconButton(
                          onPressed: () async {
                            setState(() {
                              myFavourite = !myFavourite;
                            });
                            // SharedPreferences pref =
                            //     await SharedPreferences.getInstance();
                            // var favouritesStore =
                            //     jsonDecode(pref.getString('key')!);

                            // if (favouritesStore.isEmpty) {
                            //   pref.setString('key', jsonEncode([pexel]));
                            // } else {
                            //   favouritesStore.add(pexel);
                            //   pref.setString(
                            //       'key', jsonEncode(favouritesStore));
                            // }
                            
                          },
                          icon: myFavourite
                              ? const Icon(
                                  Icons.favorite_sharp,
                                  color: Colors.orange,
                                )
                              : const Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.orange,
                                ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade100.withAlpha(100),
                        child: IconButton(
                          onPressed: () async {
                            var response = await GallerySaver.saveImage(
                                pexel.original,
                                albumName: 'media');
                            try {
                              showBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SnackBar(
                                        backgroundColor: Colors.grey.shade200,
                                        padding: const EdgeInsets.all(8),
                                        elevation: 12,
                                        duration: const Duration(seconds: 2),
                                        content: response == null
                                            ? const Text(
                                                "Image saved successfully")
                                            : const Text("Image not saved"));
                                  });
                            } catch (e) {
                              // TODO
                              print(e.toString());
                            }
                          },
                          icon: const Icon(
                            Icons.download,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
