import 'package:flutter/material.dart';
import '../allView.dart';
import 'package:yande/widget/all_widget.dart';
import 'package:yande/model/all_model.dart';
import 'package:yande/view/index/components/lazyloadGridview.dart';
import 'package:yande/view/index/components/imageCard.dart';
import 'package:yande/service/services.dart';

class ResultView extends StatefulWidget {
  final String tags;

  ResultView({
    this.tags
  });

  @override
  State<StatefulWidget> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  ScrollController _controller;
  List<ImageModel> imageList = new List();

  bool updateTagListLock = false;
  bool loadingStatus = false;
  bool noImageLoad = false;
  int pages = 1;
  int limit = 20;

  @override
  void initState() {
    super.initState();
    _controller = new ScrollController()..addListener(_scrollListener);
    this._loadPage(this.pages, this.limit);
  }


  void _scrollListener() {
    if (_controller.position.extentAfter < 50 && !loadingStatus ) {
      this.pages++;
      this._loadPage(this.pages, this.limit);
    }
  }


  @override
  dispose(){
    super.dispose();
    this._controller.dispose();
  }

  Future<void> _loadPage(int pages,int limit) async {
    this._updateImageList(await _getImageListByPagesAndLimit(pages, limit));
  }

  /// @Param pages 页码
  /// @Param limit 每页显示条数
  Future<List<ImageModel>> _getImageListByPagesAndLimit(int pages,int limit) async {
    this.loadingStatus = true;
    print(pages);
    List<ImageModel> newImageList =
      await IndexService.getIndexListByTags(widget.tags, pages, limit);
    this.loadingStatus = false;
    return newImageList;
  }

  /// @Param imageList 新的图片
  void _updateImageList(List<ImageModel> imageList) {
    if (imageList.length == 0 ) {
      this.noImageLoad = true;
    }
    this.imageList.addAll(imageList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text("搜索： ${widget.tags}"),
      ),
      body: new Container(
        child: _buildImageContent(this.imageList),
      ),
    );
  }

  _buildImageContent(List<ImageModel> imageList) {
    Widget footer = new FootProgress();
    if (this.noImageLoad) {
      footer = new Center(
        child: const Text("没有更多图片了"),
      );
    }
    if (imageList.length > 0) {
      return new LazyLoadGridView(
        controller: _controller,
        children: imageList.map((image) =>
            MainImageCard(
              image,
              imageTap: (ImageModel image) {
                this._goImageStatus(image);
              },
              collectEvent: (){
                // TODO: collect
              },
              downloadEvent: (){
                // TODO: download
              },
            )
        ).toList(),
        footer: footer,
      );
    } else {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }
  }

  _goImageStatus(ImageModel image){
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) {
              return ImageStatusView(
                image: image,
              );
            }
        ));
  }
}