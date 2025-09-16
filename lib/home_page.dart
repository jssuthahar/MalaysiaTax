import 'package:flutter/material.dart';
import 'calculator_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> _residentBrackets = const [
    {"limit": 5000, "rate": 0.01},
    {"limit": 20000, "rate": 0.03},
    {"limit": 35000, "rate": 0.08},
    {"limit": 50000, "rate": 0.13},
    {"limit": 70000, "rate": 0.21},
    {"limit": 100000, "rate": 0.24},
    {"limit": 250000, "rate": 0.24},
    {"limit": 400000, "rate": 0.25},
    {"limit": 600000, "rate": 0.26},
    {"limit": 1000000, "rate": 0.28},
    {"limit": double.infinity, "rate": 0.30},
  ];

  final double _nonResidentRate = 0.30;

  Future<void> _openYouTube() async {
    final Uri url = Uri.parse("https://www.youtube.com/@NikiBhavi");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Malaysia Tax Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // YouTube banner
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("📺 Watch & Learn — NikiBhavi Vlog",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      "Subscribe for Malaysia living cost, tax tips, and step-by-step videos.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text("Subscribe to NikiBhavi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _openYouTube,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            const SizedBox(height: 8),
            const Text("Malaysia Tax Calculator 🇲🇾",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Estimate your income tax for a chosen year. Simple, clear, and easy-to-understand.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.calculate),
              label: const Text("Start Calculation"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalculatePage()));
              },
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              "Resident Tax Brackets Preview",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Table(
              border: TableBorder.all(),
              children: [
                const TableRow(children: [
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Income Limit",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Rate",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                ..._residentBrackets.map((br) {
                  String limitStr = br['limit'] == double.infinity
                      ? "∞"
                      : br['limit'].toStringAsFixed(0);
                  return TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(limitStr)),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                            "${(br['rate'] * 100).toStringAsFixed(0)}%")),
                  ]);
                }).toList(),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              "Non-Resident Flat Rate: ${(_nonResidentRate * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red),
            ),

            const SizedBox(height: 20),
            const Text(
              "⚠️ Disclaimer: This is for reference only. Always check the official LHDN (hasil.gov.my) for up-to-date rules and official guidance.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
