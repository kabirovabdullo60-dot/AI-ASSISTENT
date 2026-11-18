import '../core/utils/local_date.dart';

/// `SaleCreate` from the API contract (API.md / Swagger).
class SaleCreateModel {
  const SaleCreateModel({
    required this.storeId,
    required this.amount,
    this.saleDate,
    this.description,
  });

  final String storeId;
  final double amount;
  final DateTime? saleDate;
  final String? description;

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'amount': amount.toStringAsFixed(2),
    if (saleDate != null) 'saleDate': formatLocalDate(saleDate!),
    'description': ?description,
  };
}
