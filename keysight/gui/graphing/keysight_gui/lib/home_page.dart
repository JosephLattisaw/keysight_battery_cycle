import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';
import 'package:keysight_gui/tab_widget.dart';

class HomePage extends HookWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();
    final tabController =
        useMemoized(() => TabController(length: 4, vsync: ticker));

    useEffect(() {
      return tabController.dispose;
    }, const []);

    return Scaffold(
      appBar: PreferredSize(
        child: const ApplicationBar(),
        preferredSize: AppBar().preferredSize,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TabWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
