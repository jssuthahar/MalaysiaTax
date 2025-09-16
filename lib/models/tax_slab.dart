// lib/models/tax_slab.dart
class TaxSlab {
  final double limit;
  final double rate;

  TaxSlab(this.limit, this.rate);
}

/// Malaysia progressive tax slabs (update as needed)
final List<TaxSlab> malaysiaTaxSlabs = [
  TaxSlab(5000, 0.00),
  TaxSlab(15000, 0.01),
  TaxSlab(15000, 0.03),
  TaxSlab(15000, 0.08),
  TaxSlab(15000, 0.14),
  TaxSlab(50000, 0.21),
  TaxSlab(200000, 0.24),
  TaxSlab(400000, 0.245),
  TaxSlab(400000, 0.25),
  TaxSlab(double.infinity, 0.30),
];

/// Calculate annual tax for resident based on progressive slabs
double calculateResidentTax(double annualSalary) {
  double remaining = annualSalary;
  double tax = 0.0;
  for (var slab in malaysiaTaxSlabs) {
    if (remaining <= 0) break;
    final taxable = remaining > slab.limit ? slab.limit : remaining;
    tax += taxable * slab.rate;
    remaining -= taxable;
  }
  return tax;
}
