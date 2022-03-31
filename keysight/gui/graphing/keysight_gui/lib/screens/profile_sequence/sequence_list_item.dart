import 'package:flutter/material.dart';

class SequenceListItem extends StatelessWidget {
  const SequenceListItem(
      {Key? key,
      required this.title,
      required this.onTap,
      required this.color,
      required this.italic})
      : super(key: key);

  final Color color;
  final String title;
  final bool italic;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Container(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontStyle: italic ? FontStyle.italic : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
