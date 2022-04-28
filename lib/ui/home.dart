import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/model/model.info.dart';
import 'package:gallery/ui/card.dart';
import 'package:gallery/ui/favourites.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'searchpage.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Pexel> data = [];
  ScrollController scrollController = ScrollController();
  bool isLargeScreen() {
    if (MediaQuery.of(context).size.width >= 600) {
      return true;
    } else {
      return false;
    }
  }

  bool isSmallScreen() {
    if (MediaQuery.of(context).size.width < 300) {
      return true;
    } else {
      return false;
    }
  }

  var url = 'https://api.pexels.com/v1/curated?page=2&per_page=27';
  getData() async {
    var api = Uri.parse(url);
    var auth = "563492ad6f91700001000001b6db29ebe1e0450bb881d9d19d7f5e75";
    // var auth = "563492ad6f9170000100000145f3369b02024112bf1ec64492195a21";
    // var auth = "563492ad6f9170000100000197ee4c4181cc43e98747111ab3e64435";
    try {
      var response = await http.get(
        api,
        headers: {
          "authorization": auth,
        },
      );
      var json = jsonDecode(response.body);
      var list = json['photos'] as List;
      url = json['next_page'];
      for (var i = 0; i < list.length; i++) {
        var element = list[i];
        var photo = Pexel.toMap(element);
        setState(() {
          data.add(photo);
        });
      }
      return data;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getData();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getData();
      }
    });
  }

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    isLargeScreen();
    isSmallScreen();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Favourites()));
        },
        backgroundColor: Colors.brown.shade500,
        child: const Icon(
          Icons.favorite_sharp,
        ),
      ),
      body: OfflineBuilder(
        connectivityBuilder: (context, connectivity, child) {
          final bool connected = connectivity != ConnectivityResult.none;
          return connected
              ? renderPage()
              : Container(
                  // color: const Color(0xFFEE4400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text('OFFLINE'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SpinKitFoldingCube(
                          size: 50,
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.brown.shade500,
                              ),
                            );
                          },
                        ),
                      ),
                      const Text('Waiting for a network connection...\nKindly connect to a WiFi or on your mobile network.', textAlign: TextAlign.center,)
                    ],
                  ),
                );
        },
        child: const Text('data'),
      ),
    );
  }

  Widget renderPage() {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                isDense: true,
                suffix: const Icon(
                  Icons.search_outlined,
                  color: Colors.grey,
                ),
                suffixIconConstraints: const BoxConstraints(
                  maxWidth: 20,
                  maxHeight: 20,
                ),
                hintText: "Search images",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              cursorColor: Colors.grey.shade500,
              onSubmitted: (text) {
                // data.clear();
                textEditingController.clear();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => Search(
                            searchQuery: text,
                          )),
                    ));
                // getData();
              },
            ),
          ),
          data.isEmpty
              ? const CircularProgressIndicator.adaptive()
              : Scrollbar(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 70,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            GridView.custom(
                              shrinkWrap: true,
                              gridDelegate: SliverWovenGridDelegate.count(
                                crossAxisCount: isSmallScreen()
                                    ? 2
                                    : isLargeScreen()
                                        ? 5
                                        : 3,
                                crossAxisSpacing: .6,
                                mainAxisSpacing: .6,
                                pattern: const [
                                  WovenGridTile(
                                    2 / 3,
                                    alignment: AlignmentDirectional.center,
                                  ),
                                  WovenGridTile(
                                    5 / 7,
                                    crossAxisRatio: .9,
                                    alignment: AlignmentDirectional.center,
                                  ),
                                ],
                              ),
                              childrenDelegate: SliverChildBuilderDelegate(
                                ((context, index) {
                                  return Stack(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PexelCard(),
                                                  settings: RouteSettings(
                                                      arguments: data[index])));
                                        },
                                        onLongPress: () {
                                          _alert(context, index);
                                        },
                                        child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Image.network(
                                            data[index].portrait,
                                            fit: BoxFit.fill,
                                            errorBuilder:
                                                (context, obj, error) {
                                              return const Text(
                                                  "Error loading image");
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                childCount: data.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  _alert(context, index) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 48,
            insetPadding: const EdgeInsets.all(8),
            child: ListTile(
              title: SizedBox(
                height: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [Text("Photographer"), Divider(thickness: 1)],
                ),
              ),
              subtitle: Text(data[index].photographer),
            ),
          );
        });
  }
}
