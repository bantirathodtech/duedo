import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'statement_parser_service.dart';

final documentScannerServiceProvider = Provider((ref) {
  final parser = ref.watch(statementParserServiceProvider);
  return DocumentScannerService(parser);
});

class DocumentReconciliationResult {
  final ParsedStatementResult parsed;
  final Obligation? matchedObligation;
  final bool isUpdate;
  final double? previousBalance;
  final double? newBalance;

  const DocumentReconciliationResult({
    required this.parsed,
    this.matchedObligation,
    required this.isUpdate,
    this.previousBalance,
    this.newBalance,
  });
}

class DocumentScannerService {
  final StatementParserService _parser;

  DocumentScannerService(this._parser);

  ParsedStatementResult? scanAndParse(String text) {
    return _parser.parseText(text);
  }

  /// Reconciles parsed document with user's existing obligations to prevent duplicates
  DocumentReconciliationResult reconcile(
    ParsedStatementResult parsed,
    List<Obligation> existingObligations,
  ) {
    final parsedTitleLower = parsed.title.toLowerCase();
    final bank = parsed.detectedBankOrInstitution?.toLowerCase();

    Obligation? bestMatch;

    for (final ob in existingObligations) {
      final obTitleLower = ob.title.toLowerCase();

      // Check title match or bank + type match
      if (obTitleLower == parsedTitleLower) {
        bestMatch = ob;
        break;
      }

      if (bank != null && obTitleLower.contains(bank)) {
        if (parsedTitleLower.contains('credit card') && obTitleLower.contains('credit card')) {
          bestMatch = ob;
          break;
        }
        if (parsedTitleLower.contains('personal loan') && obTitleLower.contains('personal loan')) {
          bestMatch = ob;
          break;
        }
        if (parsedTitleLower.contains('auto') && obTitleLower.contains('auto')) {
          bestMatch = ob;
          break;
        }
        if (parsedTitleLower.contains('home loan') && obTitleLower.contains('home loan')) {
          bestMatch = ob;
          break;
        }
      }
    }

    if (bestMatch != null) {
      return DocumentReconciliationResult(
        parsed: parsed,
        matchedObligation: bestMatch,
        isUpdate: true,
        previousBalance: bestMatch.totalBalance > 0 ? bestMatch.totalBalance : (bestMatch.amount * 12),
        newBalance: parsed.totalBalance,
      );
    }

    return DocumentReconciliationResult(
      parsed: parsed,
      matchedObligation: null,
      isUpdate: false,
      newBalance: parsed.totalBalance,
    );
  }
}
