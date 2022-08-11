import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

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
            ZoomOverlay(
              twoTouchOnly: false,
              animationDuration: const Duration(milliseconds: 400),
              child: Image.network(pexel.portrait,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width),
            ),
            Positioned(
                bottom: 25,
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
                          icon: Icon(
                            Icons.download,
                            color: Colors.brown.shade600,
                          ),
                          onPressed: () async {
                            _saveImage(pexel.portrait, context);
                          },
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade100.withAlpha(100),
                        child: IconButton(
                          onPressed: () async {
                            print('i want to share');
                            final box =
                                context.findRenderObject() as RenderBox?;
                            Share.share(
                              pexel.portrait,
                              sharePositionOrigin:
                                  box!.localToGlobal(Offset.zero) & box.size,
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

_askPermission() async {
  if (Platform.isIOS) {
    await Permission.photos.request();
  } else {
    await [Permission.storage].request();
  }
}

_saveImage(String imageUrl, context) async {
  try {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      Directory dir = await getApplicationDocumentsDirectory();
      var pathList = dir.path.split('\\');
      pathList[pathList.length - 1] = 'Pictures';
      var picturePath = pathList.join('\\');
      var round = Random();
      var netxRound = round.nextInt(100000).toString();
      var image = await File(
              join(picturePath, 'megilery_image', 'image$netxRound.jpeg'))
          .create(recursive: true);
      var response = await Dio().get((imageUrl),
          options: (Options(responseType: ResponseType.bytes)));
      await image.writeAsBytes(Uint8List.fromList(response.data));
      alert(context, 'Download successful');
    } else {
      await _askPermission();
      var response = await Dio().get((imageUrl),
          options: (Options(responseType: ResponseType.bytes)));
      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 80,
      );
      alert(context, 'Download successful');
    }

  } catch (e) {
    // ignore: todo
    // TODO
    _alert(context, 'Download fail');
  }
}

alert(context, response) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.all(8),
      elevation: 12,
      duration: const Duration(seconds: 2),
      content: response != null
          ? const Text(
              "Image saved successfully",
              style: TextStyle(color: Colors.brown),
            )
          : const Text(
              "Image not saved",
              style: TextStyle(color: Colors.brown),
            )));
}

_alert(context, e) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.all(8),
      elevation: 12,
      duration: const Duration(seconds: 2),
      content: Text(
        e.toString(),
        style: TextStyle(color: Colors.brown),
      )));
}
