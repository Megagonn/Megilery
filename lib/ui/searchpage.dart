import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gallery/model/model.info.dart';
import 'package:gallery/ui/card.dart';
import 'package:gallery/ui/favourites.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  const Search({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);
  final String searchQuery;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Pexel> data = [];
  ScrollController scrollController = ScrollController();
  getData() async {
    var url =
        "https://api.pexels.com/v1/search?query=${widget.searchQuery.toString()}&per_page=27";
    var api = Uri.parse(url);
    var auth = "563492ad6f91700001000001b6db29ebe1e0450bb881d9d19d7f5e75";
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

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: Text(widget.searchQuery.toUpperCase()),
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Column(
            children: [
              data.isEmpty
                  ? const Center(child:  CircularProgressIndicator.adaptive())
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
                                  physics: const ScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate: SliverWovenGridDelegate.count(
                                    crossAxisCount: 3,
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
                                                          arguments:
                                                              data[index])));
                                            },
                                            onLongPress: () {
                                              _alert(context, index);
                                            },
                                            child: Container(
                                                clipBehavior: Clip.hardEdge,
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child:  CachedNetworkImage(
                                                    imageUrl:
                                                        data[index].portrait,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                            colorFilter:
                                                                const ColorFilter.mode(
                                                                    Colors.transparent,
                                                                    BlendMode
                                                                        .colorBurn)),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        const CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Icon(Icons.error),
                                                  ),
                                                
                                                // Image.network(
                                                //   data[index].portrait,
                                                //   fit: BoxFit.fill,
                                                //   errorBuilder:
                                                //       (context, obj, error) {
                                                //     return const Text(
                                                //         "Error loading image");
                                                //   },
                                                // ),
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
        ),
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
