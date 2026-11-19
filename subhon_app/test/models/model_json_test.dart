import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/utils/local_date.dart';
import 'package:subhon_app/core/utils/money.dart';
import 'package:subhon_app/core/utils/phone.dart';
import 'package:subhon_app/models/employee_update_model.dart';
import 'package:subhon_app/models/monthly_payroll_model.dart';
import 'package:subhon_app/models/payment_create_model.dart';
import 'package:subhon_app/models/payroll_status.dart';
import 'package:subhon_app/models/sale_create_model.dart';
import 'package:subhon_app/models/sale_model.dart';
import 'package:subhon_app/models/store_update_model.dart';

import '../helpers/fake_backend.dart';

void main() {
  test('money arrives as a string and is parsed with double.parse; it is '
      'sent with two decimals', () {
    expect(parseMoney('1250.50'), 1250.5);
    expect(parseMoney('-30.00'), -30);
    expect(moneyToApi(1250.5), '1250.50');
    expect(moneyToApi(3000), '3000.00');
  });

  test('YYYY-MM-DD is a local calendar day, never shifted through UTC', () {
    final day = parseLocalDate('2026-11-18');
    expect(day.isUtc, isFalse);
    expect((day.year, day.month, day.day), (2026, 11, 18));
    expect(day.hour, 0);
    expect(formatLocalDate(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
  });

  test('phones: spaces and dashes removed, ^\\+?[0-9]{7,15}\$ checked', () {
    expect(normalizePhone('+992 90 123-45-67'), '+992901234567');
    expect(isValidPhone('+992 90 123-45-67'), isTrue);
    expect(isValidPhone('12-34'), isFalse);
    expect(isValidPhone('+99290123456789012'), isFalse);
  });

  test('SaleOut is read with money and dates as documented', () {
    final sale = SaleModel.fromJson(ApiJson.sale());
    expect(sale.amount, 1250.5);
    expect(sale.saleDate, DateTime(2026, 11, 18));
    expect(sale.description, 'Выручка за смену');
    expect(sale.createdAt.toUtc(), DateTime.utc(2026, 11, 18, 10));
  });

  test('MonthlyPayrollOut: rows with PAID / PARTIAL / UNPAID', () {
    for (final status in ['PAID', 'PARTIAL', 'UNPAID']) {
      final m = MonthlyPayrollModel.fromJson(
        ApiJson.monthlyPayroll(status: status),
      );
      expect(m.items.single.status, PayrollStatus.fromJson(status));
      expect(m.items.single.remainingAmount, 2000);
    }
  });

  test('requests: money with 2 decimals, dates as YYYY-MM-DD, optional '
      'fields left out when empty', () {
    expect(
      SaleCreateModel(
        storeId: 's',
        amount: 1250.5,
        saleDate: DateTime(2026, 11, 18),
      ).toJson(),
      {'storeId': 's', 'amount': '1250.50', 'saleDate': '2026-11-18'},
    );
    expect(
      PaymentCreateModel(
        employeeId: 'e',
        amount: 2000,
        month: 11,
        year: 2026,
      ).toJson(),
      {'employeeId': 'e', 'amount': '2000.00', 'month': 11, 'year': 2026},
    );
  });

  test('PUT sends only given fields; emptied optional fields are cleared '
      'with null', () {
    const update = StoreUpdateModel(name: 'Новое имя');
    expect(update.toJson(), {'name': 'Новое имя'});
    expect(update.toJson(clear: StoreUpdateModel.clearable), {
      'name': 'Новое имя',
      'address': null,
      'phone': null,
      'description': null,
      'city': null,
      'region': null,
      'type': null,
      'counters': null,
      'openingHours': null,
      'statusNote': null,
    });
    expect(
      EmployeeUpdateModel(
        monthlySalary: 3500,
        hiredAt: DateTime(2026, 2, 1),
      ).toJson(),
      {'monthlySalary': '3500.00', 'hiredAt': '2026-02-01'},
    );
  });
}
