import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomePage extends HookWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);
    final appBarHeight = AppBar().preferredSize.height;

    print("app bar height: $appBarHeight");

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Keysight Battery Charge/Discharge System',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            Image.asset(
              'assets/ibeos_logo.png',
              fit: BoxFit.contain,
              height: appBarHeight * 0.6,
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '${counter.value}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counter.value++,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
