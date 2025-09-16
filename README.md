# Malaysia Tax Calculator (Flutter Web) – Developer 

A **Flutter web app** for estimating Malaysia income tax for residents and foreigners, with fully dynamic tax brackets and non-resident rates loaded from a JSON file.

This version is **developer-friendly**, allowing easy updates to tax rules without touching the code.

---

## Features

1. **Dynamic Tax Rules**

   * Tax brackets and non-resident rate are loaded from `assets/tax_rules.json`.
   * Any updates to JSON will reflect in both **HomePage preview** and **CalculatePage**.

2. **Income Tax Calculation**

   * For **Malaysian locals**: progressive resident tax rates.
   * For **foreigners**: non-resident flat tax for first 180 days, then resident progressive if staying >182 days.
   * Calculates **monthly tax, total tax, and net income**.

3. **Interactive UI**

   * Home page shows **YouTube banner**, **tax rules preview**, and navigation button.
   * Calculator page collects **user inputs** (salary, year, arrival date, foreigner/local).

4. **Disclaimer**

   * Always refer to **LHDN (hasil.gov.my)** for official guidance.

---

## Developer Workflow

### 1. Add or Update Tax Brackets

The tax rules are stored in:

```
assets/tax_rules.json
```

**Example structure**:

```json
{
  "malaysia": {
    "non_resident_rate": 0.30,
    "resident_brackets": [
      { "limit": 5000, "rate": 0.01 },
      { "limit": 20000, "rate": 0.03 },
      { "limit": 35000, "rate": 0.08 },
      { "limit": 50000, "rate": 0.13 },
      { "limit": 70000, "rate": 0.21 },
      { "limit": 100000, "rate": 0.24 },
      { "limit": 250000, "rate": 0.24 },
      { "limit": 400000, "rate": 0.25 },
      { "limit": 600000, "rate": 0.26 },
      { "limit": 1000000, "rate": 0.28 },
      { "limit": "infinity", "rate": 0.30 }
    ]
  }
}
```

* `"limit"`: Upper bound of bracket (`"infinity"` = no upper limit).
* `"rate"`: Tax rate as decimal (0.01 = 1%).
* `"non_resident_rate"`: Flat tax rate for non-residents.

### 2. Update JSON Safely

* Place `tax_rules.json` in **`assets/`**.
* Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/tax_rules.json
```

* Run:

```bash
flutter pub get
```

### 3. Dynamic Loading in Flutter

* Both **HomePage** and **CalculatePage** load this JSON.
* HomePage shows a **preview table** of resident brackets and non-resident rate.
* CalculatePage computes **tax dynamically** using JSON rules.

**Benefits:**

* You can update tax rules **without modifying Dart code**.
* Supports new brackets, rates, or policy changes instantly.

---

## Example HomePage JSON Loader (Developer-Friendly)

```dart
Future<void> _loadTaxRules() async {
  final String jsonStr = await rootBundle.loadString('assets/tax_rules.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final malaysia = data['malaysia'] ?? {};
  final brackets = malaysia['resident_brackets'] ?? [];
  final nonRate = malaysia['non_resident_rate']?.toDouble() ?? 0.3;

  List<Map<String, dynamic>> processed = brackets.map((br) {
    double limit = br['limit'] == "infinity"
        ? double.infinity
        : (br['limit'] as num).toDouble();
    return {
      'limit': limit,
      'rate': (br['rate'] as num).toDouble(),
    };
  }).toList();

  setState(() {
    _residentBrackets = processed;
    _nonResidentRate = nonRate;
    _loading = false;
  });
}
```

---

## Running the Project

1. Clone the repository:

```bash
git clone <repo-url>
cd malaysia_tax_calculator
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run in browser:

```bash
flutter run -d chrome
```

4. Build for production:

```bash
flutter build web
```

* The output is in `build/web/`.
* Can be hosted on **GitHub Pages** or any static web host.

---

## Developer Tips

* **Add new tax brackets**: Simply append to `resident_brackets` in JSON.
* **Change non-resident rate**: Update `non_resident_rate`.
* **Preview updates**: HomePage automatically refreshes table after reload.
* **Dynamic calculation**: CalculatePage reads the JSON at runtime for calculations.
* **Future improvements**: Could add **tax deduction categories**, **marital status adjustments**, etc., by expanding JSON.

---

## Dependencies

* Flutter SDK 3.x+
* `url_launcher`: for YouTube links

```yaml
dependencies:
  flutter:
    sdk: flutter
  url_launcher: ^6.2.1
```

---

## License

MIT License ©  Suthahar Jegatheesan

