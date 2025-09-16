import 'package:flutter/material.dart';
import 'tax_config.dart';
import 'package:url_launcher/url_launcher.dart';

class CalculatePage extends StatefulWidget {
  const CalculatePage({super.key});

  @override
  State<CalculatePage> createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage> {
  final TextEditingController _salaryController = TextEditingController();
  bool _isForeigner = false;
  DateTime? _arrivalDate;
  int _selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> _breakdown = [];
  double _totalSalary = 0;
  double _totalTax = 0;
  double _netIncome = 0;
  String _residencyNote = "";

  // Compute resident tax for an annual income using TaxConfig.residentBrackets
  double _calculateResidentAnnualTax(double annualIncome) {
    double tax = 0;
    double prevLimit = 0;
    double remaining = annualIncome;

    for (var bracket in TaxConfig.residentBrackets) {
      final double limit = bracket["limit"];
      final double rate = bracket["rate"];

      double taxable;
      if (limit == double.infinity) {
        taxable = remaining;
      } else {
        taxable = (annualIncome > limit) ? (limit - prevLimit) : (remaining);
      }

      if (taxable > 0) {
        tax += taxable * rate;
        remaining -= taxable;
      }

      prevLimit = limit;
      if (remaining <= 0) break;
    }

    return tax;
  }

  // Resident start date = arrivalDate + 182 days (i.e. after completing 182 days)
  DateTime? _residentStartDate(DateTime arrival) {
    return arrival.add(const Duration(days: 182));
  }

  // Build user-friendly explanation / timeline and compute monthly breakdown
  void _calculate() {
    // reset
    _breakdown = [];
    _totalSalary = 0;
    _totalTax = 0;
    _netIncome = 0;
    _residencyNote = "";

    final double monthlySalary = double.tryParse(_salaryController.text) ?? 0;
    if (monthlySalary <= 0) {
      setState(() {});
      return;
    }

    // Build months for the selected year
    List<DateTime> months =
        List.generate(12, (i) => DateTime(_selectedYear, i + 1, 1));

    DateTime? residentFrom;
    bool fullYearNonResident = false;

    if (_isForeigner) {
      if (_arrivalDate == null) {
        // require arrival date
        setState(() {});
        return;
      }

      // If arrival is after the selected year end or before selected year start handle properly
      // For residency determination within selected year, compute days remaining in that year from arrival
      final DateTime endOfSelectedYear = DateTime(_arrivalDate!.year, 12, 31);
      final int daysRemainingThisYear =
          endOfSelectedYear.difference(_arrivalDate!).inDays + 1;

      // residentFrom = arrival + 182 days
      residentFrom = _residentStartDate(_arrivalDate!);

      // If arrival in selected year BUT daysRemainingThisYear < 183 => cannot become resident in this year
      if (_arrivalDate!.year == _selectedYear && daysRemainingThisYear < 183) {
        fullYearNonResident = true;
        _residencyNote =
            "You arrived on ${_formatDate(_arrivalDate!)} — not enough days left in $_selectedYear to meet 183-day rule. You will be Non-Resident for $_selectedYear (30% flat).";
      }

      // If arrival after selectedYear (arriving next year), treat selected year as before arrival (no salary)
      // If arrival earlier than selectedYear, residentFrom may be before selectedYear -> they are resident for selectedYear
    } else {
      _residencyNote = "Local Malaysian — progressive resident tax applies for the year.";
    }

    // precompute annual resident tax when resident months exist (apply same monthly split)
    double annualResidentTax = _calculateResidentAnnualTax(monthlySalary * 12);
    double monthlyResidentTax = annualResidentTax / 12;

    for (var m in months) {
      Map<String, dynamic> row = {
        "monthLabel": _monthLabel(m),
        "salary": 0.0,
        "tax": 0.0,
        "rateLabel": "—",
        "status": "Before Arrival / N/A"
      };

      // If foreigner and arrival is after this month => before arrival
      if (_isForeigner) {
        if (_arrivalDate != null && m.isBefore(DateTime(_arrivalDate!.year, _arrivalDate!.month, 1))) {
          // before arrival => no salary
          row["status"] = "Before Arrival";
          row["salary"] = 0.0;
        } else if (fullYearNonResident &&
            _arrivalDate != null &&
            _arrivalDate!.year == _selectedYear &&
            m.isAtSameMomentAs(DateTime(_arrivalDate!.year, _arrivalDate!.month, 1)) ||
            (fullYearNonResident && _arrivalDate != null && m.isAfter(DateTime(_arrivalDate!.year, _arrivalDate!.month, 1)))) {
          // if arrival in selected year but fullYearNonResident, then months from arrival onwards taxed at 30%
          if (_arrivalDate != null && (m.isBefore(DateTime(_arrivalDate!.year, _arrivalDate!.month, 1)))) {
            row["salary"] = 0.0;
            row["status"] = "Before Arrival";
          } else {
            row["salary"] = monthlySalary;
            row["tax"] = monthlySalary * TaxConfig.nonResidentRate;
            row["rateLabel"] = "${(TaxConfig.nonResidentRate * 100).toStringAsFixed(0)}% (Non-resident)";
            row["status"] = "Non-resident (30%)";
          }
        } else {
          // If residentFrom is within or before selected year and this month is on/after residentFrom => resident tax
          if (_arrivalDate != null && residentFrom != null && (m.isAtSameMomentAs(DateTime(residentFrom.year, residentFrom.month, 1)) || m.isAfter(DateTime(residentFrom.year, residentFrom.month, 1)))) {
            // resident month
            row["salary"] = monthlySalary;
            row["tax"] = monthlyResidentTax;
            row["rateLabel"] = "Progressive (resident)";
            row["status"] = "Resident (progressive)";
          } else {
            // If arrival in this year and month >= arrival month but before residentFrom => non-resident 30%
            if (_arrivalDate != null && m.isAtSameMomentAs(DateTime(_arrivalDate!.year, _arrivalDate!.month, 1)) || (_arrivalDate != null && (m.isAfter(DateTime(_arrivalDate!.year, _arrivalDate!.month, 1)) && (residentFrom == null || m.isBefore(DateTime(residentFrom.year, residentFrom.month, 1)))))) {
              row["salary"] = monthlySalary;
              row["tax"] = monthlySalary * TaxConfig.nonResidentRate;
              row["rateLabel"] = "${(TaxConfig.nonResidentRate * 100).toStringAsFixed(0)}% (Non-resident)";
              row["status"] = "Non-resident (30%)";
            } else {
              // arrival not in this year -> if arrival before this year then they might be resident
              // check if arrival_date is before this year and residentFrom <= this month -> resident
              if (_arrivalDate != null && _arrivalDate!.isBefore(DateTime(_selectedYear, 1, 1))) {
                // arrival earlier than this year: check if residentFrom <= this month
                DateTime rFrom = residentFrom ?? _arrivalDate!;
                if (rFrom.isBefore(m) || rFrom.isAtSameMomentAs(m)) {
                  row["salary"] = monthlySalary;
                  row["tax"] = monthlyResidentTax;
                  row["rateLabel"] = "Progressive (resident)";
                  row["status"] = "Resident (progressive)";
                } else {
                  // still non-resident
                  row["salary"] = monthlySalary;
                  row["tax"] = monthlySalary * TaxConfig.nonResidentRate;
                  row["rateLabel"] = "${(TaxConfig.nonResidentRate * 100).toStringAsFixed(0)}% (Non-resident)";
                  row["status"] = "Non-resident (30%)";
                }
              } else {
                // default: no salary (if arrival in future) or apply resident if local
                if (!_isForeigner) {
                  row["salary"] = monthlySalary;
                  row["tax"] = monthlyResidentTax;
                  row["rateLabel"] = "Progressive (resident)";
                  row["status"] = "Resident (progressive)";
                } else {
                  // case arrival in future of selected year -> before arrival handled above; else fallback:
                  row["salary"] = 0.0;
                  row["tax"] = 0.0;
                  row["rateLabel"] = "—";
                  row["status"] = "Before Arrival";
                }
              }
            }
          }
        }
      } else {
        // Local: resident all year
        row["salary"] = monthlySalary;
        row["tax"] = monthlyResidentTax;
        row["rateLabel"] = "Progressive (resident)";
        row["status"] = "Resident (progressive)";
      }

      _breakdown.add(row);
      _totalSalary += (row["salary"] as double);
      _totalTax += (row["tax"] as double);
      _netIncome += (row["salary"] as double) - (row["tax"] as double);
    }

    // Build clear residency note
    if (_isForeigner && _arrivalDate != null) {
      final DateTime residentFrom = _residentStartDate(_arrivalDate!)!;
      if (residentFrom.year > _selectedYear) {
        _residencyNote =
            "You arrived on ${_formatDate(_arrivalDate!)} — you will be Non-Resident for $_selectedYear. If you stay through ${_monthLabel(residentFrom)} you may become Resident in ${residentFrom.year}.";
      } else {
        _residencyNote =
            "You arrived on ${_formatDate(_arrivalDate!)} — you become Resident from ${_monthLabel(residentFrom)} ${residentFrom.year}.";
      }
    }

    // done
    setState(() {});
  }

  String _monthLabel(DateTime d) {
    final names = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${names[d.month - 1]} ${d.year}";
  }

  String _formatDate(DateTime d) {
    final names = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${d.day} ${names[d.month - 1]} ${d.year}";
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Summary for $_selectedYear",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Total Salary:", style: TextStyle(fontWeight: FontWeight.w600)),
            Text("MYR ${_totalSalary.toStringAsFixed(2)}"),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Total Tax:", style: TextStyle(fontWeight: FontWeight.w600)),
            Text("MYR ${_totalTax.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Net Income:", style: TextStyle(fontWeight: FontWeight.w600)),
            Text("MYR ${_netIncome.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          if (_residencyNote.isNotEmpty)
            Text(_residencyNote, style: const TextStyle(color: Colors.deepPurple)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Malaysia Tax Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Inputs
          const Text("1) Enter monthly salary (before tax)",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "e.g. 5000",
              prefixText: "MYR ",
            ),
          ),
          const SizedBox(height: 12),

          // Year selector
          Row(children: [
            const Text("2) Select tax year", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Tooltip(message: "Choose the tax year you want to estimate", child: const Icon(Icons.info, size: 16)),
          ]),
          const SizedBox(height: 6),
          DropdownButton<int>(
            value: _selectedYear,
            items: List.generate(6, (i) => DateTime.now().year + i)
                .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
                .toList(),
            onChanged: (v) => setState(() => _selectedYear = v!),
          ),
          const SizedBox(height: 12),

          // Foreigner switch + tooltip
          Row(children: [
            const Text("3) Are you a foreigner? ", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Tooltip(
              message:
                  "Foreigners: subject to 30% flat while non-resident. If stay ≥183 days in a year, you become tax resident and progressive rates apply.",
              child: Icon(Icons.info_outline, size: 18),
            ),
            const Spacer(),
            Switch(value: _isForeigner, onChanged: (v) => setState(() {
              _isForeigner = v;
              if (!_isForeigner) _arrivalDate = null;
            })),
          ]),
          const SizedBox(height: 6),

          // Arrival date picker (only for foreigners)
          if (_isForeigner)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("4) Select arrival date to Malaysia", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_arrivalDate == null ? "Pick arrival date" : _formatDate(_arrivalDate!)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(_selectedYear, 1, 1),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _arrivalDate = picked);
                },
              ),
              const SizedBox(height: 8),
            ]),

          // Calculate button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_circle),
              label: const Text("Calculate"),
              onPressed: () {
                _breakdown.clear();
                _totalSalary = 0;
                _totalTax = 0;
                _netIncome = 0;
                _residencyNote = "";
                _calculate();
              },
            ),
          ),

          const SizedBox(height: 16),

          // Summary card
          if (_breakdown.isNotEmpty) _buildSummaryCard(),

          const SizedBox(height: 12),

          // Explanation text (plain-language)
          if (_breakdown.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _isForeigner && _arrivalDate != null
                      ? "Explanation: You arrived on ${_formatDate(_arrivalDate!)}. Months before arrival show 0 income. Months between arrival and completing 183 days are taxed at 30% (non-resident). After completing 183 days you are taxed using Malaysia's progressive resident brackets (shown as 'Progressive' below)."
                      : "Explanation: All months are taxed using Malaysia's progressive resident tax brackets.",
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Legend
          if (_breakdown.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Legend", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text("30% (Non-resident): Flat rate for non-resident foreigner months."),
                  const SizedBox(height: 4),
                  const Text("Progressive (Resident): Monthly share of resident tax computed from progressive annual slabs."),
                ]),
              ),
            ),

          const SizedBox(height: 10),

          // Monthly table (simple list)
          if (_breakdown.isNotEmpty)
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                const TableRow(children: [
                  Padding(padding: EdgeInsets.all(8), child: Text("Month", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8), child: Text("Salary (MYR)", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8), child: Text("Tax (MYR)", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8), child: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                ..._breakdown.map((r) => TableRow(children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text(r["monthLabel"])),
                  Padding(padding: const EdgeInsets.all(8), child: Text((r["salary"] as double).toStringAsFixed(2))),
                  Padding(padding: const EdgeInsets.all(8), child: Text((r["tax"] as double).toStringAsFixed(2))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(r["rateLabel"])),
                ])),
              ],
            ),

          const SizedBox(height: 14),

          // Footer: disclaimer & subscribe reminder
          const Text(
            "Disclaimer: This calculator is for reference only. Check official LHDN (hasil.gov.my) for precise rules and reliefs. This app uses editable tax rules from assets/tax_rules.json.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => launchUrl(Uri.parse("https://www.youtube.com/@NikiBhavi")),
            child: const Text(
              "Learn more on NikiBhavi Vlog — Subscribe!",
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ]),
      ),
    );
  }
}
