import 'package:flutter/material.dart';
import 'package:flutter_api_clean_architecture/features/articles/presentation/controller/article_controller.dart';
import 'package:flutter_api_clean_architecture/utils/route/app_route.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'dart:async';

class ArticleView extends StatefulWidget {
  @override
  _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final _controller = Get.find<ArticleController>();
  List<String> _data = [];
  List<int> _id = [];
  final _searchQuery = new TextEditingController();
  List<String> _filterData = [];
  Timer? _debounce;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _controller.articles.length; i++) {
      _data.add(_controller.articles[i].title);
      _id.add(_controller.articles[i].articleId);
    }
    _filterData = _data;
    // print(_controller.articles[0].title);
    _searchQuery.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _searchQuery,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.greenAccent,
                  width: 1.0,
                )),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.blueAccent,
                  width: 1.0,
                )),
                hintText: 'Search here',
              ),
            ),
            Expanded(
              child: Obx(
                () => _controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemBuilder: (ctx, index) => ListTile(
                          onTap: () {
                            AppRoute.navigateToSingleArticle(_id[index]);
                          },
                          title: Text(_filterData[index]),
                        ),
                        itemCount: _filterData.length,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchText != _searchQuery.text) {
        _filterData = _data;
        setState(() {
          _filterData = _filterData
              .where((item) => item
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.text.toString().toLowerCase()))
              .toList();
        });
      }
      searchText = _searchQuery.text;
    });
  }

  @override
  void dispose() {
    _searchQuery.removeListener(_onSearchChanged);
    _searchQuery.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
