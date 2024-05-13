import 'dart:async';

import 'package:controle_qualite/Global/GlobalVar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class StatusBar extends StatefulWidget {
  @override
  _StatusBarState createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  String nonSentElementNumberString = '';
  String msg = "Verification des élements en attente";
  Timer updateNumber;
  Color statusColor = Colors.orange;

  bool isSending = false;

  void stateMessage() {
    if (nonSentElementNumberString == "0") {
      msg = "$nonSentElementNumberString élément en attente";
      statusColor = myDarkCyan;
    } else if (nonSentElementNumberString == "1") {
      msg = "$nonSentElementNumberString élément en attente";
      statusColor = Colors.red;
    } else {
      msg = "$nonSentElementNumberString éléments en attente";
      statusColor = Colors.red;
    }
  }

  @override
  void dispose() {
    updateNumber.cancel();
    super.dispose();
  }

  @override
  void initState() {
    updateNumber = new Timer.periodic(Duration(seconds: 1), (Timer t) async {
      setState(() {});

      if (mounted) {
        nonSentElementNumberString = queueBox.length.toString();
        stateMessage();
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.signika(
            textStyle: TextStyle(
              fontSize: 18,
              color: statusColor,
            ),
          ),
        ),
        if (mutex)
          IconButton(
              icon: Icon(Icons.refresh_outlined),
              color: Colors.white,
              onPressed: () {
                sendData();
              })
      ],
    );
  }
}
