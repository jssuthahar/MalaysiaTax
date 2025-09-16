// lib/disclaimer_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DisclaimerPage extends StatelessWidget {
  void _openLHDN() async {
    final url = Uri.parse("https://www.hasil.gov.my/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Disclaimer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("⚠️ Terms & Conditions",
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            Text(
                "This calculator is for reference only. Calculations may differ from official LHDN results. Always verify tax details with the official LHDN website."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openLHDN,
              child: Text("Go to LHDN Website"),
            ),
            Spacer(),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/'),
                icon: Icon(Icons.subscriptions),
                label: Text("👉 Subscribe to NikiBhavi Vlog"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
