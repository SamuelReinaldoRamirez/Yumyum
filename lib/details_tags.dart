import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/tag.dart';

class DetailsTags extends StatefulWidget {
  DetailsTags({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  _DetailsTagsState createState() => _DetailsTagsState(restaurant);
}

class _DetailsTagsState extends State<DetailsTags> {
  Restaurant restaurant;

  List<Tag> tagList = [];

  _DetailsTagsState(this.restaurant);

  @override
  void initState() {
    super.initState();
    _fetchTagList();
  }

  Future<void> _fetchTagList() async {
    List<Tag> tags = await CallEndpointService.getTagsFromXanos();
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tags.map((tag) => Text(tag.tag)).toList(),
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Tag>> _groupTagsByType() {
    Map<String, List<Tag>> tagsByType = {};
    tagList.forEach((tag) {
      tagsByType.putIfAbsent(tag.type, () => []);
      tagsByType[tag.type]!.add(tag);
    });

    List<Tag> filteredTags = _filterTags(restaurant.getTagStr().cast<String>());

    Map<String, List<Tag>> filteredTagsByType = {};
    filteredTags.forEach((tag) {
      filteredTagsByType.putIfAbsent(tag.type, () => []);
      filteredTagsByType[tag.type]!.add(tag);
    });

    return filteredTagsByType;
  }

  List<Tag> _filterTags(List<String> tagIds) {
    return tagList.where((tag) => tagIds.contains(tag.id)).toList();
  }
}
