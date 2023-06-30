import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  const CardButton({Key? key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
        Expanded(
          child: Container(
            // margin: EdgeInsets.only(right: 10),
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                '$text',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 2,
                style:
                    GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
