import 'package:flutter/material.dart';

class PayWithbtn extends StatelessWidget {
  final String? btntitle;
  final Color? btnTextColor;
  // final int? selectedIndex;

  const PayWithbtn({Key? key, this.btntitle, this.btnTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Text(
      btntitle.toString(),
      style: TextStyle(color: btnTextColor),
    ));
  }
}
