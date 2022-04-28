
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class PexelCard extends StatefulWidget {
  const PexelCard({Key? key}) : super(key: key);

  @override
  _PexelCardState createState() => _PexelCardState();
}

class _PexelCardState extends State<PexelCard> {
  bool myFavourite = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic pexel = ModalRoute.of(context)!.settings.arguments;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            pexel.alt.toString().toUpperCase(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            var favouritesStore =
                                (pref.getStringList('favourite'));

                            if (favouritesStore == null) {
                              pref.setStringList(
                                  'favourite', ([pexel.portrait]));
                            } else {
                              if (!favouritesStore.contains(pexel.portrait)) {
                                favouritesStore.add(pexel.portrait);
                                pref.setStringList(
                                    'favourite', (favouritesStore));
                              }
                            }
                          },
                          icon: myFavourite
                              ? Icon(
                                  Icons.favorite_sharp,
                                  color: Colors.brown.shade600,
                                )
                              : Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.brown.shade600,
                                ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade100.withAlpha(100),
                        child: IconButton(
                          onPressed: () async {
                            var response = await GallerySaver.saveImage(
                              pexel.portrait,
                              albumName: 'media',
                              toDcim: true,
                            );
                            try {
                              alert(context, response);
                            } catch (e) {
                              // ignore: todo
                              // TODO
                              _alert(context, e);
                            }
                          },
                          icon: Icon(
                            Icons.download,
                            color: Colors.brown.shade600,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade100.withAlpha(100),
                        child: IconButton(
                          onPressed: () async {
                            print('i want to share');
                            // var response = await GallerySaver.saveImage(
                            //     pexel.original,
                            //     albumName: 'media');
                            // try {
                            //   alert(context, response);
                            // } catch (e) {
                            //   // TODO
                            //   _alert(context, e);
                            // }
                            Share.shareFiles(
                              [pexel.portrait],
                              mimeTypes: [],
                              sharePositionOrigin: Rect.fromCenter(
                                  center: const Offset(100, 100),
                                  width: 100,
                                  height: 100),
                            );
                          },
                          icon: Icon(
                            Icons.share_sharp,
                            color: Colors.brown.shade600,
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

alert(context, response) {
  showBottomSheet(
      context: context,
      builder: (context) {
        return SnackBar(
            backgroundColor: Colors.grey.shade200,
            padding: const EdgeInsets.all(8),
            elevation: 12,
            duration: const Duration(seconds: 2),
            content: response == null
                ? const Text("Image saved successfully")
                : const Text("Image not saved"));
      });
}

_alert(context, e) {
  showBottomSheet(
      context: context,
      builder: (context) {
        return SnackBar(
            backgroundColor: Colors.grey.shade200,
            padding: const EdgeInsets.all(8),
            elevation: 12,
            duration: const Duration(seconds: 2),
            content: Text(e.toString()));
      });
}
