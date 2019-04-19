import 'dart:async';

import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery/app/utils/Network.dart';
import 'package:gallery/app/models/subCategories.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SubCategoryPage extends StatefulWidget {
  SubCategoryPage(this.id);

  String id;

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    NetworkUtils.checkConnectivity(_scaffoldKey);
    _getName();
  }

  int _page = 0;
  var _mainCatName = '';

  _getName() {
    Future getData = getSubCategories(widget.id, 'subname');

    getData.then((data) {
      //print(data.catname);
      setState(() {
        if (data.catname != "") {
          _mainCatName = data.catname;
        } else {
          _mainCatName = "PHOTO GALLERY";
        }
      });
    });
  }

  SubCategories subCat;

  @override
  Widget build(BuildContext context) {
    final double barHeight = 20.0;
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(statusbarHeight + barHeight),
        child: AppBar(
          title: Text(
            _mainCatName,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.5, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
      ),
      body: PageView(
        children: <Widget>[
          Offstage(
              offstage: _page != 0,
              child: TickerMode(
                enabled: _page == 0,
                child: FutureBuilder<SubCategories>(
                  future: getSubCategories(widget.id, ''),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.data.error == true) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            "assets/images/technoCan.png",
                            fit: BoxFit.cover,
                            height: 150.0,
                            alignment: Alignment.topCenter,
                          ),
                          Container(
                            alignment: FractionalOffset.center,
                            child: Text(
                              "${snapshot.data.message}",
                              style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      SubCategories subCats;
                      subCats = snapshot.data;

                      //setCatoryName(subCats.mainCategory);

                      var crossAxisCount = 2;
                      var mainAxisSpacing = 0.0;

                      if (subCats.template == "gallery") {
                        crossAxisCount = 3;
                        mainAxisSpacing = 10.0;
                      }

                      return CustomScrollView(
                        primary: false,
                        slivers: <Widget>[
                          SliverPadding(
                            padding: EdgeInsets.all(10.0),
                            sliver: SliverGrid.count(
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: mainAxisSpacing,
                              crossAxisCount: crossAxisCount,
                              children: createVideoCardItem(subCats, context),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(10.0),
                            sliver: SliverGrid.count(
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: mainAxisSpacing,
                              crossAxisCount: crossAxisCount,
                              children:
                                  createSubCategoryCardItem(subCats, context),
                            ),
                          )
                        ],
                      );
                    }
                  },
                ),
              ))
        ],
      ),
    );
  }
}

List<Widget> createSubCategoryCardItem(subcats, BuildContext context) {
  // Children list for the list.
  List<Widget> listElementWidgetList = List<Widget>();
  List<PhotoViewGalleryPageOptions> _galleryPageOptions =
      List<PhotoViewGalleryPageOptions>();

  if (subcats.template == "categories") {
    var subData = subcats.subdata;

    if (subcats != null) {
      var lengthOfList = subData.length;

      for (int i = 0; i < lengthOfList; i++) {
        SubCategoriesModel subcat = subData[i];

        // Image URL
        var imageURL = "YOUR IMAGE URL" +
            subcat.sectionPhoto;

        // List item created with an image of the poster
        var listItem = GridTile(
            footer: Container(
              height: 35.0,
              child: GridTileBar(
                backgroundColor: Colors.black54,
                title: Center(
                  child: Text(subcat.sectionName),
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (subcat.id != "0") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubCategoryPage(subcat.id),
                    ),
                  );
                }
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: imageURL,
                fit: BoxFit.contain,
              ),
            ));
        listElementWidgetList.add(listItem);
      }
    }
  } else {
    var subData = subcats.gallery;

    if (subcats != null) {
      var lengthOfList = subData.length;

      for (int i = 0; i < lengthOfList; i++) {
        Galleries subcat = subData[i];
        String _heroTag = "picture";

        if (subcat.photoName.contains('.')) {
          // Image URL
          var imageURL =
              "YOUR IMAGE URL" + subcat.photoName;

          var galleryItem = PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageURL),
            maxScale: PhotoViewComputedScale.covered * 0.9,
            minScale: PhotoViewComputedScale.contained * 0.8,
            heroTag: _heroTag,
            //initialScale: PhotoViewComputedScale.contained * 0.9,
          );

          _galleryPageOptions.add(galleryItem);

          var listItem = Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey[200]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenWrapper(
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            imageProvider: NetworkImage(imageURL),
                            index: i,
                            galleryPageOptions: _galleryPageOptions,
                            minScale: 0.1,
                            isVideo: false,
                            videoUrl: subcat.photoName,
                          ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: imageURL,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                ),
              ));

          listElementWidgetList.add(listItem);
        }
      }
    }
  }

  return listElementWidgetList;
}

List<Widget> createVideoCardItem(subcats, BuildContext context) {
  // Children list for the list.
  List<Widget> listElementWidgetList = List<Widget>();
  List<PhotoViewGalleryPageOptions> _galleryPageOptions =
      List<PhotoViewGalleryPageOptions>();

  if (subcats.template == "gallery") {
    var subData = subcats.gallery;

    if (subcats != null) {
      var lengthOfList = subData.length;
      var listItem;

      for (int i = 0; i < lengthOfList; i++) {
        Galleries subcat = subData[i];
        String _heroTag = "video";

        // Image URL
        var imageURL = "";

        if (!subcat.photoName.contains('.')) {
          imageURL =
              "https://i.ytimg.com/vi/" + subcat.photoName + "/hqdefault.jpg";
          _heroTag = subcat.photoName;

          var galleryItem = PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageURL),
            maxScale: PhotoViewComputedScale.covered * 0.9,
            minScale: PhotoViewComputedScale.contained * 0.8,
            heroTag: _heroTag,
            //initialScale: PhotoViewComputedScale.contained * 0.9,
          );

          _galleryPageOptions.add(galleryItem);

          listItem = Container(
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey[200]),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                )
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenWrapper(
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          imageProvider: NetworkImage(imageURL),
                          index: i,
                          galleryPageOptions: _galleryPageOptions,
                          minScale: 0.1,
                          isVideo: true,
                          videoUrl: subcat.photoName,
                        ),
                  ),
                );
              },
              child: Column(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: imageURL,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                  ),
                  Container(
                      width: double.infinity,
                      height: 27.5,
                      color: Colors.black,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 20,
                              color: Colors.yellowAccent[700],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "VIDEO",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          );

          listElementWidgetList.add(listItem);
        }
      }
    }
  }

  return listElementWidgetList;
}

class FullScreenWrapper extends StatefulWidget {
  FullScreenWrapper({
    this.imageProvider,
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.index,
    this.galleryPageOptions,
    this.isVideo,
    this.videoUrl,
  }) : pageController = PageController(initialPage: index);

  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final int index;
  final PageController pageController;
  final List<PhotoViewGalleryPageOptions> galleryPageOptions;
  final bool isVideo;
  final String videoUrl;

  @override
  State<StatefulWidget> createState() {
    return _FullScreenWrapperState();
  }
}

class _FullScreenWrapperState extends State<FullScreenWrapper> {
  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['games', 'lego', 'mobile'],
    contentUrl: 'https://flutter.io',
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  int currentIndex;
  int currentAdIndex = 0;
  InterstitialAd myInterstitial;
  bool _isCurrentVideo = false;
  String _currentVideoUrl;

  @override
  void initState() {
    currentIndex = widget.index;
    super.initState();

    FirebaseAdMob.instance.initialize(
      //appId: "YOUR LIVE APP ID",
      appId: FirebaseAdMob.testAppId,
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentAdIndex++;
      _isCurrentVideo = false;

      if (currentAdIndex == 2) {
        myInterstitial = InterstitialAd(
          // Replace the testAdUnitId with an ad unit id from the AdMob dash.
          // https://developers.google.com/admob/android/test-ads
          // https://developers.google.com/admob/ios/test-ads
          adUnitId: InterstitialAd.testAdUnitId,
          targetingInfo: targetingInfo,
          listener: (MobileAdEvent event) {
            print("InterstitialAd event is $event");
          },
        );
        myInterstitial..load();
      }

      if (currentAdIndex == 3) {
        currentAdIndex = 0;
        myInterstitial.show();
      }

      currentIndex = index;

      // Current item is video?
      var gOption = widget.galleryPageOptions[index];

      if (gOption.heroTag != "picture") {
        _isCurrentVideo = true;
        _currentVideoUrl = gOption.heroTag;
      }
    });
  }

  Widget _videoPlayer() {
    if (widget.isVideo || _isCurrentVideo) {

      // PLEASE CHECK THIS URL FOR VIDEO ERROR ON IOS
      // https://github.com/sarbagyastha/youtube_player_flutter/issues/2    
      return Container(
        width: double.infinity,
        child: Center(
          child: YoutubePlayer(
            context: context,
            videoId: _isCurrentVideo ? _currentVideoUrl : widget.videoUrl,
            autoPlay: true,
            showVideoProgressIndicator: true,
            videoProgressIndicatorColor: Colors.amber,
            progressColors: ProgressColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
          ),
        ),
      );
    }

    return PhotoViewGallery(
      scrollPhysics: const BouncingScrollPhysics(),
      pageOptions: widget.galleryPageOptions,
      loadingChild: widget.loadingChild,
      backgroundDecoration: widget.backgroundDecoration,
      pageController: widget.pageController,
      onPageChanged: onPageChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            _videoPlayer(),
          ],
        ),
      ),
    );
  }
}
