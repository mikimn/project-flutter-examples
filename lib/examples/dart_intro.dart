import 'dart:io';


/*********************** CONST VS FINAL *********************/
void constVsFinalExample() {
  var fullyMutable = [1,2,3];
  // Works fine
  fullyMutable[1] += 1;
  // Works fine
  fullyMutable = [4,5];

  final valuesAreMutable = [1,2,3];
  // Works fine
  valuesAreMutable[1] += 1;
  // Error: Can't assign to the final variable 'valuesAreMutable'.
  // valuesAreMutable = [4,5];

  const fullyImmutable = [1,2,3];
  // Error: Unsupported operation: indexed set
  // fullyImmutable[1] += 1;
  // Error: Can't assign to the const variable 'fullyImmutable'.
  // fullyImmutable = [4,5];

  var constValues = const [1,2,3];
  // Error: Unsupported operation: indexed set
  // constValues[1] += 1;
  // Works fine
  constValues = const [4,5];
  print("Finished well");
}


/******************* ASYNC/AWAIT HANDLING *******************/
Future<String> fetchUsername() async {
  return Future.delayed(
    Duration(seconds: 2),
    () => 'XÆA-Xii'
  );
}

Future<String> logoutUser() async {
  // Succesful logout
  return Future.delayed(
    Duration(seconds: 2),
    () => 'XÆA-Xii'
  );

  // Failed logout
  // throw Exception('Good catch');
}

Future<String> greetUser() async {
  var username = await fetchUsername();
  return 'Hello $username';
}

Future<String> sayGoodbye() async {
  try {
    var result = await logoutUser();
    return '$result Thanks, see you next time';
  } catch(e) {
    return 'Failed to logout user: $e';
  }
}

void asyncAwaitExample() async {
  print(await greetUser());
  print(await sayGoodbye());
}


/****************** GENERATORS AND STREAMS ******************/
Iterable<int> syncCountDown(int number) sync* {
  while (number > 0) {
    sleep(const Duration(milliseconds: 500));
    yield number--;
  }
}

void generatorExample() {
  Iterable<int> syncSequence1 = syncCountDown(5);
  Iterable<int> syncSequence2 = syncCountDown(5);
  print('Starting Sync...');

  for (int value in syncSequence1) {
    print('Generator 1: ${value}');
  }
  for (int value in syncSequence2) {
    print('Generator 2: ${value}');
  }

  print('Done Sync...');
}

Stream<int> asyncCountDown(int number) async* {
  while (number > 0) {
    sleep(const Duration(milliseconds: 500));
    yield number--;
  }
}

void streamExample() {
  Stream<int> asyncSequence1 = asyncCountDown(5);
  Stream<int> asyncSequence2 = asyncCountDown(5);
  print('Starting Async...');

  asyncSequence1.listen((int value) {
    print('Stream 1: ${value}');
  });
  asyncSequence2.listen((int value) {
    print('Stream 2: ${value}');
  });

  print('Done Async...');
}


/******************* FACTORY CONSTRUCTORS *******************/
class Point {
  static final Map<String, Point> _cache = <String, Point>{};
  double x, y;

  factory Point(double x, double y) {
    print('Point factory called: ${x},${y}');
    return _cache.putIfAbsent(
      '${x},${y}', () => Point._createInstance(x,y));
  }

  Point._createInstance(this.x, this.y) {
    print('Create Instance called: ${x},${y}');
  }
}

void factoryCtorExample() {
  var p1 = Point(1,2);
  var p2 = Point(1,2);
  var p3 = Point(123,342);
}


/********************* DART INTRO MAIN **********************/
void main() async {
  constVsFinalExample();
  await asyncAwaitExample();
  await generatorExample();
  await streamExample();
  factoryCtorExample();
}
