// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loction_taxi/util/const.dart';

import 'package:loction_taxi/widgets/card_button.dart';

class AnimatedContainerWidget extends StatefulWidget {
  final double? dH;
  final String? homeAddress;
  final String? workAddress;

  const AnimatedContainerWidget(
      {Key? key, this.dH, this.homeAddress, this.workAddress})
      : super(key: key);

  @override
  State<AnimatedContainerWidget> createState() =>
      _AnimatedContainerWidgetState();
}

class _AnimatedContainerWidgetState extends State<AnimatedContainerWidget> {
  bool isTapped = false;
  FirebaseAuth ffAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: widget.dH,
        padding: EdgeInsets.only(top: 30, left: 15, right: 8),
        decoration: BoxDecoration(
            color: Colors.black.withGreen(50),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !isTapped
                ? RichText(
                    text: TextSpan(
                      text: 'Hi: ',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                            text: userCurrentInfo == null
                                ? 'User'
                                : userCurrentInfo!.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                      ],
                    ),
                  )
                : SizedBox(),
            SizedBox(
              height: 03,
            ),
            !isTapped
                ? Text(
                    "This is your location",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                : SizedBox(),
            // Padding(
            //   padding: const EdgeInsets.only(
            //     top: 8,
            //   ),
            //   child: TextField(
            //     decoration: InputDecoration(
            //         contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
            //         fillColor: Colors.white,
            //         filled: true,
            //         focusedBorder: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(30.0),
            //             borderSide:
            //                 BorderSide(width: 0.8, color: Color(0xFF000000))),
            //         border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(30.0),
            //             borderSide: const BorderSide(width: 0.8)),
            //         enabledBorder: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(30.0),
            //             borderSide:
            //                 BorderSide(width: 0.8, color: Color(0xFF000000))),
            //         hintText: "Search location",
            //         prefixIcon: const Icon(
            //           Icons.search,
            //           size: 30,
            //         ),
            //         suffixIcon: IconButton(
            //             icon: const Icon(Icons.clear), onPressed: () {})),
            //     onTap: () {
            //       setState(() {
            //         isTapped = !isTapped;
            //       });
            //     },
            //   ),
            // ),
            !isTapped
                ? Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.only(top: 05),
                      itemCount: 2,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        return CardButton(
                          icon: index == 0 ? Icons.location_pin : Icons.work,
                          text: index == 0
                              ? '${widget.homeAddress}'
                              : '${widget.workAddress}',
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 5,
                        );
                      },
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
