import 'package:flutter/material.dart'; 


  Widget buildHorizontalNode(BuildContext context) {
    return Container(
      height: 20,
      width: 5,
      decoration: BoxDecoration(
      color: const Color(0xFF4c6759),
      borderRadius: BorderRadius.all(Radius.circular(24.0))
    ),
    );
  }

  Widget buildVerticalNode(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      color: const Color(0xFF4c6759),
      borderRadius: BorderRadius.all(Radius.circular(24.0))
    ),
      height: 5,
      width: 15,

    );
  }