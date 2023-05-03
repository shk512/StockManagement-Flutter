import 'package:flutter/material.dart';

class RowInfoDisplay extends StatelessWidget {
  final String value;
  final String label;
  const RowInfoDisplay({Key? key,required this.value,required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(label,style: const TextStyle(fontWeight: FontWeight.w900),)
        ),
        Expanded(
            flex: 3,
            child: Text(value)
        ),
      ],
    );
  }
}
