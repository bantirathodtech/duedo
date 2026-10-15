import 'package:flutter_test/flutter_test.dart';
import 'package:duedo/services/statement_parser_service.dart';
import 'package:duedo/models/app_enums.dart';

void main() {
  late StatementParserService parser;

  setUp(() {
    parser = StatementParserService();
  });

  group('StatementParserService Tests', () {
    test('returns null for empty or whitespace string', () {
      expect(parser.parseText(''), isNull);
      expect(parser.parseText('   '), isNull);
    });

    test('parses Indian Bank Sanction Letter accurately', () {
      const text = '''
      Sanction Letter: HDFC Bank Personal Loan.
      Sanctioned Amount: Rs. 5,00,000.
      Monthly EMI: Rs. 13,200.
      Interest Rate: 10.75% p.a.
      Tenure: 48 months.
      Due on: 5th of every month.
      ''';

      final result = parser.parseText(text);
      expect(result, isNotNull);
      expect(result!.title, contains('HDFC Bank'));
      expect(result.totalBalance, equals(500000.0));
      expect(result.monthlyAmount, equals(13200.0));
      expect(result.interestRate, equals(10.75));
      expect(result.emiDurationMonths, equals(48));
      expect(result.dueDayOfMonth, equals(5));
      expect(result.type, equals(ObligationType.emi));
    });

    test('parses Credit Card statement with total & minimum due', () {
      const text = '''
      ICICI Bank Credit Card Statement for Oct 2026.
      Card ending in 4012.
      Total Amount Due: ₹ 45,800.
      Minimum Amount Due: ₹ 2,290.
      Payment Due Date: on 22nd.
      ''';

      final result = parser.parseText(text);
      expect(result, isNotNull);
      expect(result!.title, contains('ICICI Bank'));
      expect(result.title, contains('Credit Card'));
      expect(result.totalBalance, equals(45800.0));
      expect(result.monthlyAmount, equals(2290.0));
      expect(result.interestRate, equals(36.0)); // Default CC APR
      expect(result.dueDayOfMonth, equals(22));
      expect(result.priority, equals(PriorityLevel.high));
    });

    test('parses Rent obligation', () {
      const text = 'Monthly Rent of Rs. 24,000 due on 1st of every month.';

      final result = parser.parseText(text);
      expect(result, isNotNull);
      expect(result!.title, equals('Rent'));
      expect(result.monthlyAmount, equals(24000.0));
      expect(result.type, equals(ObligationType.recurring));
      expect(result.category, equals('Rent'));
    });

    test('handles fallback amounts without explicit labels', () {
      const text = 'Loan transfer confirmed ₹ 3,50,000 with installment ₹ 9,500.';

      final result = parser.parseText(text);
      expect(result, isNotNull);
      expect(result!.totalBalance, equals(350000.0));
      expect(result.monthlyAmount, equals(9500.0));
    });
  });
}
