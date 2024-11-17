// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/model/restaurant.dart';
import 'package:yummap/model/tag.dart';

class RestoTags extends StatefulWidget {
  const RestoTags({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  // ignore: no_logic_in_create_state
  _RestoTagsState createState() => _RestoTagsState(restaurant);
}

class _RestoTagsState extends State<RestoTags> {
  Restaurant restaurant;

  List<Tag> tagList = [];

  _RestoTagsState(this.restaurant);

  @override
  void initState() {
    super.initState();
    //oulala pourquoi on fait ca
    _fetchTagList();
  }

  Future<void> _fetchTagList() async {
    List<Tag> tags = await CallEndpointService().getTagsFromXanos();
    setState(() {
      tagList = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Tag>> filteredTagsByType = _groupTagsByType();

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails des tags de ${restaurant.name}'),
      ),
      body: ListView.builder(
        itemCount: filteredTagsByType.length,
        itemBuilder: (context, index) {
          String type = filteredTagsByType.keys.elementAt(index);
          List<Tag> tags = filteredTagsByType[type]!;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tags.map((tag) => Text(tag.tag)).toList(),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Tag>> _groupTagsByType() {
    Map<String, List<Tag>> tagsByType = {};
    for (var tag in tagList) {
      tagsByType.putIfAbsent(tag.type, () => []);
      tagsByType[tag.type]!.add(tag);
    }

    //List<Tag> filteredTags = _filterTags(restaurant.getTagStr().cast<String>());

    List<Tag> filteredTags =
        _filterTags(intListToStringList(restaurant.getTagStr()));

    Map<String, List<Tag>> filteredTagsByType = {};
    for (var tag in filteredTags) {
      filteredTagsByType.putIfAbsent(tag.type, () => []);
      filteredTagsByType[tag.type]!.add(tag);
    }

    return filteredTagsByType;
  }

//à mettre dans un helper si ca aide mieux que le cast
  List<String> intListToStringList(List<int> inputList) {
    List<String> outputList = [];
    for (int i in inputList) {
      outputList.add(i.toString());
    }
    return outputList;
  }

  List<Tag> _filterTags(List<String> tagIds) {
    return tagList.where((tag) => tagIds.contains(tag.id)).toList();
  }
}
