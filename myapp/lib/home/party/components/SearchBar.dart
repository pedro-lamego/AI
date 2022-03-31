import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/musicManager.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';
import 'package:outline_search_bar/outline_search_bar.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  SearchBar(this.controller, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: "Search Here",
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
