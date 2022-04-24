import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gallery/model/model.info.dart';
import 'package:gallery/service/api.dart';
import 'package:gallery/ui/card.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Pexel> data = [];
  ScrollController scrollController = ScrollController();
  var url = 'https://api.pexels.com/v1/curated?page=2&per_page=6';
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
      // print(list);
      for (var i = 0; i < list.length; i++) {
        var element = list[i];
        var photo = Pexel.toMap(element);
        setState(() {
          data.add(photo);
        });
      }

      print(data.length);
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
        onPressed: (){}, backgroundColor: Colors.orange.shade500,child: const Icon(Icons.favorite_sharp,),),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: data.isEmpty
            ? const CircularProgressIndicator.adaptive()
            : Scrollbar(
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
                                                  arguments: data[index])));
                                    },
                                    onLongPress: () {
                                      _alert(context, index);
                                    },
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Image.network(
                                        data[index].portrait,
                                        fit: BoxFit.fill,
                                        errorBuilder: (context, obj, error) {
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
