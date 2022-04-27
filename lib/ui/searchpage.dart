import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gallery/model/model.info.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  const Search({
    Key? key,required this.searchQuery,
  }) : super(key: key);
  final String searchQuery;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Pexel> data = [];
  ScrollController scrollController = ScrollController();
  var url = 'https://api.pexels.com/v1/curated?page=2&per_page=6';
  getData() async {
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
      print(data.length);
      return data;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
