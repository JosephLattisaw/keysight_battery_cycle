import 'package:flutter/material.dart';

class SequenceListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(180),
      child: Column(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Sequences",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: [
              Material(
                child: InkWell(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Sequence 1",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ),
              Material(
                child: InkWell(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Sequence 2",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
