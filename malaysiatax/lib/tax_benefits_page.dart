// lib/tax_benefits_page.dart
import 'package:flutter/material.dart';

class TaxBenefitsPage extends StatefulWidget {
  @override
  _TaxBenefitsPageState createState() => _TaxBenefitsPageState();
}

class _TaxBenefitsPageState extends State<TaxBenefitsPage> {
  bool epf = false;
  bool insurance = false;
  bool education = false;

  double _savings = 0.0;

  void _calculateSavings() {
    _savings = 0;
    if (epf) _savings += 4000;
    if (insurance) _savings += 3000;
    if (education) _savings += 2000;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tax Benefits Estimator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: Text("EPF / Retirement savings"),
              value: epf,
              onChanged: (val) => setState(() => epf = val!),
            ),
            CheckboxListTile(
              title: Text("Insurance premiums"),
              value: insurance,
              onChanged: (val) => setState(() => insurance = val!),
            ),
            CheckboxListTile(
              title: Text("Education expenses"),
              value: education,
              onChanged: (val) => setState(() => education = val!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateSavings,
              child: Text("Estimate Savings"),
            ),
            SizedBox(height: 20),
            if (_savings > 0)
              Text(
                "🎉 You could reduce taxable income by RM $_savings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            Spacer(),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/disclaimer'),
              child: Text("⚠️ View Terms & Conditions"),
            )
          ],
        ),
      ),
    );
  }
}
