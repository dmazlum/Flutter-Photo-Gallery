import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:gallery/app/utils/Network.dart';
import 'package:gallery/app/models/mainCategories.dart';
import 'package:gallery/app/pages/subCategory.dart';

class HomePage extends StatefulWidget {
  static final String routeName = 'home';

  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var _page = 0;

  @override
  void initState() {
    super.initState();
    NetworkUtils.checkConnectivity(_scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    final double barHeight = 20.0;
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(statusbarHeight + barHeight),
        child: new AppBar(
          title: new Text(
            'PHOTO GALLERY',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.4, 0.9),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
      ),
      body: PageView(
        children: <Widget>[
          new Offstage(
              offstage: _page != 0,
              child: new TickerMode(
                enabled: _page == 0,
                child: new FutureBuilder(
                  future: getMainCategories(),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (!snapshot.hasData)
                      return new Container(
                        child: new Center(
                          child: new CircularProgressIndicator(),
                        ),
                      );
                    List mainCats = snapshot.data;
                    return new CustomScrollView(
                      primary: false,
                      slivers: <Widget>[
                        new SliverPadding(
                          padding: const EdgeInsets.all(8.0),
                          sliver: SliverGrid.count(
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 0.0,
                            crossAxisCount: 2,
                            children:
                                createMainCategoryCardItem(mainCats, context),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ))
        ],
      ),
    );
  }

  List<Widget> createMainCategoryCardItem(
      List<MainCategories> maincats, BuildContext context) {
    // Children list for the list.
    List<Widget> listElementWidgetList = new List<Widget>();

    if (maincats != null) {
      var lengthOfList = maincats.length;

      for (int i = 0; i < lengthOfList; i++) {
        MainCategories maincat = maincats[i];
        // Image URL
        var imageURL = "YOUR REMOTE URL" +
            maincat.sectionPhoto;
        // List item created with an image of the poster
        var listItem = new GridTile(
          footer: Container(
            height: 35.0,
            child: new GridTileBar(
              backgroundColor: Colors.black54,
              title: Center(
                child: Text(maincat.sectionName),
              ),
            ),
          ),
          child: new GestureDetector(
            onTap: () {
              if (maincat.id != "0") {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (_) => new SubCategoryPage(maincat.id),
                  ),
                );
              }
            },
            child: new FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: imageURL,
              fit: BoxFit.contain,
            ),
          ),
        );

        listElementWidgetList.add(listItem);
      }
    }
    return listElementWidgetList;
  }
}
