import 'package:flutter/material.dart';

class SequenceListItem extends StatelessWidget {
  const SequenceListItem(
      {Key? key, required this.title, required this.onTap, required this.color})
      : super(key: key);

  final Color color;
  final String title;

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
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
