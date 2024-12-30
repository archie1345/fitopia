import 'package:fitopia/page/home.dart';
import 'package:fitopia/page/settings.dart';
import 'package:flutter/material.dart';

class FloatingNavigationBar extends StatelessWidget {
  final void Function()? onHomePressed;
  // final void Function()? onChartPressed;
  final void Function()? onSettingsPressed;

  const FloatingNavigationBar({
    super.key,
    this.onHomePressed,
    // this.onChartPressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.black),
                onPressed: onHomePressed ?? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
              // IconButton(
              //   icon: const Icon(Icons.show_chart, color: Colors.black),
              //   onPressed: onChartPressed,
              // ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: onSettingsPressed ?? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
