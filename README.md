

# Malaysia Tax Calculator (Flutter Web)

A **user-friendly Flutter web app** to estimate Malaysia income tax for residents and foreigners. The app allows users to input their salary, arrival date (for foreigners), and calculates monthly and yearly taxes. It also provides a preview of Malaysian tax brackets and non-resident flat tax rates.

---

## Features

1. **Income Tax Calculation**

   * For **Malaysian locals** (resident progressive tax rates).
   * For **foreigners** (non-resident flat rate for initial months, then resident progressive if staying >182 days).
   * Calculates **monthly tax, total tax, and net income**.

2. **Interactive UI**

   * Home page with **YouTube promotion banner** for NikiBhavi channel.
   * Navigation to **calculator page** for user input and tax computation.
   * Easy-to-read **monthly breakdown** with percentages.

3. **Tax Rules Preview**

   * Shows **resident brackets** and **non-resident flat rate**.
   * Hardcoded for instant display (JSON can be used dynamically in the calculator).

4. **User Inputs**

   * Monthly salary in MYR.
   * Year of calculation.
   * Foreigner or local selection.
   * Arrival date for foreigners.

5. **Disclaimer**

   * Reminds users to always refer to **official LHDN (hasil.gov.my)** for the latest tax rules.

6. **YouTube Integration**

   * Button to open NikiBhavi channel for tutorials.

---

## Screenshots

*(Add screenshots here of HomePage, Table Preview, and CalculatorPage with monthly breakdown)*

---

## Project Structure

```
malaysia_tax_calculator/
│
├─ lib/
│   ├─ main.dart
│   ├─ home_page.dart         # Home page with YouTube banner & tax preview
│   ├─ calculator_page.dart   # Tax calculation page
│   └─ tax_config.dart        # Optional: Load tax brackets & non-resident rate
│
├─ assets/
│   └─ tax_rules.json         # JSON file for dynamic tax brackets
│
├─ pubspec.yaml
├─ README.md
└─ web/
    └─ index.html             # Flutter web entrypoint
```

---

## Setup Instructions

1. **Clone the repository**

```bash
git clone <your-repo-url>
cd malaysia_tax_calculator
```

2. **Install Flutter dependencies**

```bash
flutter pub get
```

3. **Run Flutter web app**

```bash
flutter run -d chrome
```

4. **Build for web (optional)**

```bash
flutter build web
```

* The build will be in the `build/web/` folder.
* Can be hosted on **GitHub Pages** or any static hosting.

---

## Assets

* `assets/tax_rules.json`
  Sample structure:

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

* Used in **CalculatePage** for dynamic tax computation.

---

## Usage

1. Open the app in the browser.

2. On **HomePage**:

   * See the **YouTube banner** for NikiBhavi.
   * See **resident tax brackets preview** and **non-resident rate**.
   * Click **Start Calculation** to navigate to the calculator page.

3. On **CalculatorPage**:

   * Enter your **monthly salary**.
   * Select **year**.
   * Choose **foreigner or local**.
   * For foreigners, select **arrival date**.
   * Click **Calculate**.
   * View **monthly breakdown**, **total salary**, **total tax**, and **net income**.

---

## Notes

* Non-resident foreigners are taxed **30% flat for first 180 days**.
* After 182 days, if still in Malaysia, **progressive resident tax applies**.
* The calculator uses **dynamic JSON tax rules**, making it easy to update in future.
* All results are **estimates**; always verify with **LHDN (hasil.gov.my)**.

---

## Dependencies

* **Flutter SDK 3.x or higher**
* **url\_launcher**: for opening YouTube links

```yaml
dependencies:
  flutter:
    sdk: flutter
  url_launcher: ^6.2.1
```

---

## License

MIT License © Suthahar Jegatheesan

