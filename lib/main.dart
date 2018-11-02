import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

// This is the type used by the popup menu below.
enum PopupActions { reload }

class _MyHomePageState extends State<MyHomePage> {
  // This call to setState tells the Flutter framework that something has
  // changed in this State, which causes it to rerun the build method below
  // so that the display can reflect the updated values. If we changed
  // _counter without calling setState(), then the build method would not be
  // called again, and so nothing would appear to happen.

  bool _loaded = false;
  bool _failed = false;
  List<dynamic> _json;
  Text _failure = Text(
    "Could not load data.\nPlease, retry later",
    textAlign: TextAlign.center,
    style: TextStyle(inherit: false),
  );

  bool _isLoading() {
    return _loaded == false && _failed == false;
  }

  bool _isLoaded() {
    return _loaded == true && _failed == false;
  }

  bool _isNotLoaded() {
    return _loaded == false && _failed == false;
  }

  void _markDataLoading() {
    setState(() {
      _loaded = false;
      _failed = false;
    });
  }

  void _markDataLoadingFailed() {
    setState(() {
      _loaded = false;
      _failed = true;
    });
  }

  void _markDataLoadingSucceeded() {
    setState(() {
      _loaded = true;
      _failed = false;
    });
  }

  void _setJson(List<dynamic> json) {
    setState(() {
      _json = json;
    });
  }

  @override
  Widget build(BuildContext context) {
    SliverAppBar appBar = SliverAppBar(
      pinned: true,
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Text('My GitHub Viewer', textAlign: TextAlign.right),
        background: Image.asset(
            'assets/images/writing-content-notes-ss-1920.jpg',
            fit: BoxFit.cover),
      ),
      actions: <Widget>[
        // overflow menu
        PopupMenuButton<PopupActions>(
            onSelected: (PopupActions action) {
              _markDataLoading();
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<PopupActions>>[
                  PopupMenuItem<PopupActions>(
                    value: PopupActions.reload,
                    child: Text('Reload'),
                  )
                ])
      ],
    );

    Widget sliverBody;

    /*
    Widget sliverBody = SliverFixedExtentList(
      itemExtent: 50.0,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
    */

    /*
    Widget sliverBody = SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        );
      },
      childCount: 1,
    ));
    */

    /*
    Widget sliverBody = SliverGrid(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: ListView(
            children: <Widget>[text, CircularProgressIndicator()],
          ),
        );
      }, childCount: 2),
      gridDelegate:
          SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 1000.0),
    );
    */

    if (_isNotLoaded()) {
      _loadRepositories().then((json) {
        _setJson(json);
        _markDataLoadingSucceeded();
      }).catchError((error) {
        print(error);
        _markDataLoadingFailed();
      });
    }

    /*
    FutureBuilder<List<dynamic>>(
        future: _loadRepositories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
          } else if (snapshot.hasError) {
            print(snapshot.error);
          }
        });
    */

    if (_isLoading()) {
      sliverBody = SliverPadding(
          padding: EdgeInsets.all(100.0),
          sliver: SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator());
            }, childCount: 1),
          ));
    } else if (_isLoaded()) {
      sliverBody = SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return Container(
              alignment: Alignment.center,
              child: createSliverWidget(_json[index]));
        }, childCount: _json.length),
      );
    } else {
      sliverBody = SliverPadding(
          padding: EdgeInsets.all(100.0),
          sliver: SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Container(alignment: Alignment.center, child: _failure);
            }, childCount: 1),
          ));
    }
    /*
    return FutureBuilder<List<Widget>>(
      future: _loadCurrencies(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          sliverList = SliverList(
            delegate: SliverChildListDelegate(snapshot.data),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          sliverList = SliverList(
            delegate: SliverChildListDelegate(texts),
          );
        }

        // By default, show a loading spinner
        return CustomScrollView(
          slivers: <Widget>[
            appBar,
            sliverList
          ],
        );
      },
    );
    */

    return CustomScrollView(
      slivers: <Widget>[appBar, sliverBody],
    );

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    /*

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              print('Ololo');
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<ListView>(
          future: _loadCurrencies(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("Could not load data. Please, retry later");
            }

            // By default, show a loading spinner
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => print("Floating Action Button pressed"),
        tooltip: 'Increment',
        child: new Icon(Icons.menu),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: new BottomAppBar(
        color: Colors.green,
        child: Container(height: 50.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
    */
  }
}

Future<List<dynamic>> _loadRepositories() async {
  try {
    final response =
        await http.get('https://api.github.com/users/starichkovva/repos');
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return json.decode(response.body);
    } else {
      print(response.statusCode);
      print(response.body);
      // If that call was not successful, throw an error.
      throw Exception('$response.statusCode $response.body');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

/*
ListView createListView(List<dynamic> json) {
  return new ListView(children: createWidgets(json));
}

List<Widget> createWidgets(List<dynamic> json) {
  List<Widget> widgets = new List();
  if (json != null) {
    json.forEach((list) => widgets.add(new ListTile(
          title: Text(list['full_name']),
          subtitle: Text(list['clone_url']),
        )));
  }
  return widgets;
}
*/

Widget createSliverWidget(dynamic json) {
  return Container(
      child: Text(json['full_name'], style: TextStyle(inherit: false)));
}
