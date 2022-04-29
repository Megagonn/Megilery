import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class Favourites extends StatefulWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  getFavourites() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var favourites = sharedPreferences.getStringList('favourite');
    return favourites;
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Favourites"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text('Clear all'),
                  onTap: () async {
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.remove("favourite");
                    setState(() {});
                  },
                )
              ];
            },
            icon: const Icon(Icons.menu),
          )
        ],
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        child: FutureBuilder(
            future: getFavourites(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              } else {
                var favourite = snapshot.data;
                return SingleChildScrollView(
                  child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: favourite != null ? favourite.length : 1,
                      itemBuilder: (context, index) {
                        return favourite != null
                            ? Stack(
                                children: [
                                  Container(
                                    clipBehavior: Clip.hardEdge,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Image.network(
                                      favourite[index],
                                      fit: BoxFit.fill,
                                      errorBuilder: (context, obj, error) {
                                        return const Text(
                                            "Error loading image");
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 15,
                                    left: 72,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.grey.shade100.withAlpha(100),
                                      child: IconButton(
                                        onPressed: () async {
                                          _saveImage(favourite[index], context);
                                        },
                                        icon: Icon(
                                          Icons.download,
                                          color: Colors.brown.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: Colors.brown.shade100,
                                padding: const EdgeInsets.all(5),
                                child: const Center(
                                  child: Text("No favourite added yet"),
                                ),
                              );
                      }),
                );
              }
            }),
      ),
    ));
  }
}

_askPermission() async {
  if (Platform.isIOS) {
    await Permission.photos.request();
  } else {
    await [Permission.storage].request();
  }
}

_saveImage(String imageUrl, BuildContext context) async {
  try {
    await _askPermission();
    var response = await Dio()
        .get((imageUrl), options: (Options(responseType: ResponseType.bytes)));
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 100,
    );

    // print(result);
    alert(context, 'Download successful');
  } catch (e) {
    // ignore: todo
    // TODO
    _alert(context, 'Download failed');
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
            content: response != null
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
