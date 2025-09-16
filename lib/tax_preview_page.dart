import 'package:flutter/material.dart';
import 'tax_config.dart';

class TaxPreviewPage extends StatelessWidget {
  const TaxPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double exampleSalary = 6000; // example monthly salary

    return Scaffold(
      appBar: AppBar(title: const Text("Tax Slot Preview")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resident Tax Slot Preview (Progressive Rates)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...TaxConfig.residentBrackets.map((bracket) {
              double monthlyLimit = bracket['limit'] / 12;
              double monthlyTax = (monthlyLimit) * bracket['rate'];
              return ListTile(
                title: Text("Income Range: 0 - ${monthlyLimit.toStringAsFixed(2)} MYR"),
                subtitle: Text("Rate: ${(bracket['rate'] * 100).toStringAsFixed(0)}%"),
                trailing: Text("Tax: ${monthlyTax.toStringAsFixed(2)} MYR"),
              );
            }).toList(),
            const SizedBox(height: 20),
            const Text(
              "Non-Resident: Flat 30% tax applied per month.",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            const Text(
              "Disclaimer: This is an example preview for illustration only. Actual tax depends on income and residency status.",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
