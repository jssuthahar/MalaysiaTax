import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TaxConfig {
  static double nonResidentRate = 0.30;
  static List<Map<String, dynamic>> residentBrackets = [];

  /// Load JSON config from assets/tax_rules.json
  static Future<void> loadConfig() async {
    final String response = await rootBundle.loadString('assets/tax_rules.json');
    final data = json.decode(response);

    nonResidentRate =
        (data["malaysia"]["non_resident_rate"] as num).toDouble();

    residentBrackets = (data["malaysia"]["resident_brackets"] as List)
        .map((b) => {
              "limit": b["limit"] == "infinity"
                  ? double.infinity
                  : (b["limit"] as num).toDouble(),
              "rate": (b["rate"] as num).toDouble()
            })
        .toList();
  }
}
