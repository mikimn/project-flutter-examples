import 'package:android_course/examples/animations.dart';
import 'package:android_course/examples/clock.dart';
import 'package:android_course/examples/firebase/firebase_screen.dart';
import 'package:android_course/examples/future_builder.dart';
import 'package:android_course/examples/networking/pokemon_page.dart';
import 'package:android_course/examples/provider/person_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (_) => MyHomePage(title: 'Flutter Demo Home Page'),
        '/clock': (_) => ClockScreen(),
        '/future_builder': (_) => FutureBuilderExampleScreen(),
        '/person_provider': (_) => PersonScreen(),
        '/firebase': (_) => FirebaseScreen(),
        '/pokemon': (_) => PokemonPage(),
        '/animations': (_) => AnimationsPageOne()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const Map<String, String> routes = {
    'StatefulWidget (Clock)': '/clock',
    'FutureBuilder': '/future_builder',
    'Simple Provider (Person)': '/person_provider',
    'Firebase Examples': '/firebase',
    'Pokemon Example (HTTP requests)': '/pokemon',
    'Animations Example': '/animations'
  };

  _sendTokenToServer(String token) {}

  @override
  void initState() {
    super.initState();
    // _sendTokenToServer is a function you must implement according to your needs.
    // Usually, you can store the token for each user in your Cloud Firestore instance
    final messaging = FirebaseMessaging();
    messaging.onTokenRefresh.listen((token) => _sendTokenToServer(token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: routes.entries
                    .map((e) => Row(
                          children: [
                            Expanded(
                              child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, e.value);
                                  },
                                  child: Text(e.key)),
                            ),
                          ],
                        ))
                    .toList()),
          ),
        ));
  }
}

/// StatelessWidget example
class DecoratedText extends StatelessWidget {
  final Widget child;

  DecoratedText(this.child);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(color: Colors.blueAccent),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: child,
        ));
  }
}
