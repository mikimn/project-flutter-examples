import 'package:android_course/examples/animations.dart';
import 'package:android_course/examples/clock.dart';
import 'package:android_course/examples/device/camera.dart';
import 'package:android_course/examples/device/camera_repository.dart';
import 'package:android_course/examples/device/conectivity.dart';
import 'package:android_course/examples/device/location.dart';
import 'package:android_course/examples/firebase/firebase_screen.dart';
import 'package:android_course/examples/future_builder.dart';
import 'package:android_course/examples/networking/pokemon_page.dart';
import 'package:android_course/examples/provider/person_screen.dart';
import 'package:android_course/examples/ui/slivers.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityRepository()),
        FutureProvider(
            initialData: CameraRepository([]),
            create: (_) => availableCameras()
                .then((cameras) => CameraRepository(cameras))),
        FutureProvider(
            initialData: LocationRepository.stub(),
            create: (_) => LocationRepository.getRepository())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.brown,
            accentColor: Colors.green,
            buttonTheme: theme.buttonTheme.copyWith(
              buttonColor: Colors.green,
              textTheme: ButtonTextTheme.primary,
            ),
            textTheme: theme.textTheme.copyWith(
                subtitle1: theme.textTheme.subtitle1!
                    .copyWith(color: Colors.grey.shade300))),
        routes: {
          '/': (_) => MyHomePage(
              title: 'Workshop Examples in Flutter',
              subtitle: 'Project in Android, Winter 2020/21, Technion CS'),
          '/clock': (_) => ClockScreen(),
          '/future_builder': (_) => FutureBuilderExampleScreen(),
          '/person_provider': (_) => PersonScreen(),
          '/firebase': (_) => FirebaseScreen(),
          '/pokemon': (_) => PokemonPage(),
          '/animations': (_) => AnimationsPageOne(),
          '/slivers': (_) => SliversPage(),
          '/camera': (_) => CameraExamplesPage(),
          '/connectivity': (_) => ConnectivityPage(),
          '/location': (_) => LocationScreen()
        },
      ),
    );
  }

  @override
  void dispose() {
    // if (_locationRepository != null) {
    //   _locationRepository.dispose();
    // }
    super.dispose();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title, this.subtitle}) : super(key: key);

  final String? title;
  final String? subtitle;

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
    'Animations Example': '/animations',
    'Slivers': '/slivers',
    'Camera': '/camera',
    'Connectivity': '/connectivity',
    'Location': '/location'
  };

  _sendTokenToServer(String token) {}

  @override
  void initState() {
    super.initState();
    // _sendTokenToServer is a function you must implement according to your needs.
    // Usually, you can store the token for each user in your Cloud Firestore instance
    final messaging = FirebaseMessaging.instance;
    messaging.onTokenRefresh.listen((token) => _sendTokenToServer(token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title!),
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.subtitle1,
            )
          ],
        ),
      ),
      body: Center(
        child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 2),
            children: routes.entries
                .map((e) => Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, e.value);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                            child: Text(e.key)),
                      ),
                    ))
                .toList()),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Builder(
          builder: (context) => Container(
            height: 75,
            child: IconButton(
              tooltip: 'App Information',
              iconSize: 30.0,
              icon: Icon(Icons.info_outline_rounded),
              onPressed: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                showAboutDialog(
                    context: context,
                    applicationName: 'Workshop Examples in Flutter',
                    applicationVersion: packageInfo.version,
                    applicationIcon: FlutterLogo(),
                    applicationLegalese:
                        'Flutter and the related logo are trademarks of Google LLC. We are not endorsed by or affiliated with Google LLC'
                        '\n\n'
                        'The Technion logo is a trademark of the Technion, Israel Institue of Technology, and is used for academic purposes only'
                        '\n\n'
                        'App icon designed by Freepik from Flaticon');
              },
            ),
          ),
        ),
      ),
    );
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
