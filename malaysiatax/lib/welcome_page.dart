// lib/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatelessWidget {
  void _openYouTube() async {
    final url = Uri.parse("https://www.youtube.com/@NikiBhavi");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("👋 Welcome to Malaysia Tax Calculator",
                  style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 20),
              Text(
                "This tool helps you estimate your salary, taxes, and savings in Malaysia.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _openYouTube,
                icon: Icon(Icons.subscriptions),
                label: Text("Subscribe to NikiBhavi Vlog"),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/calculator'),
                child: Text("Start Calculator →"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
