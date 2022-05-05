import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TabWidget extends HookWidget {
  const TabWidget(
      {Key? key,
      required this.tabs,
      required this.tabWidgets,
      this.useShadow = true})
      : assert(tabs.length == tabWidgets.length),
        super(key: key);

  final List<Widget> tabs;
  final List<Widget> tabWidgets;
  final bool useShadow;

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();
    final tabController =
        useMemoized(() => TabController(length: tabs.length, vsync: ticker));

    useEffect(() {
      return tabController.dispose;
    }, const []);

    return Column(
      children: [
        Container(
          color: Color(Colors.black.value).withOpacity(0.95),
          child: TabBar(
            tabs: List.generate(
              tabs.length,
              (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: tabs.elementAt(index),
              ),
            ),
            controller: tabController,
            indicator: BoxDecoration(color: Colors.blue.shade900),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: useShadow
                  ? null
                  : Border.all(color: Colors.black.withAlpha(100), width: 2.0),
              boxShadow: !useShadow
                  ? null
                  : [
                      BoxShadow(
                        blurRadius: 5,
                        spreadRadius: 4,
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(0, 5),
                      )
                    ],
            ),
            child: TabBarView(
              children: List.generate(
                  tabWidgets.length, (index) => tabWidgets.elementAt(index)),
              controller: tabController,
            ),
          ),
        ),
      ],
    );
  }
}
