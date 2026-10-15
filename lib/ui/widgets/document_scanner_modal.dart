import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../models/app_enums.dart';
import '../../services/database.dart';
import '../../services/document_scanner_service.dart';
import '../../services/haptic_service.dart';
import '../../services/statement_parser_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../repositories/obligation_repository.dart';

class DocumentScannerModal extends ConsumerStatefulWidget {
  final bool isDark;

  const DocumentScannerModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DocumentScannerModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<DocumentScannerModal> createState() => _DocumentScannerModalState();
}

class _DocumentScannerModalState extends ConsumerState<DocumentScannerModal> {
  final TextEditingController _textController = TextEditingController();
  DocumentReconciliationResult? _reconciliation;
  bool _isProcessing = false;

  final List<String> _sampleSnippets = [
    'HDFC Bank Loan Sanction Letter: Sanction Amount ₹2,50,000 at 14.5% interest per annum. Monthly EMI ₹12,450 payable on 5th of every month. Tenure 24 months.',
    'SBI Credit Card e-Statement: Total Amount Due is Rs. 48,200. Minimum Amount Due is Rs. 2,400. Due Date: 18th Oct. Interest rate: 42% p.a.',
    'Bajaj Finserv Consumer Loan: Loan amount ₹85,000. Monthly installment ₹7,080. Due date is 2nd. 12 months tenure.',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _processText(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _reconciliation = null;
      });
      return;
    }

    setState(() => _isProcessing = true);

    final scannerService = ref.read(documentScannerServiceProvider);
    final parsed = scannerService.scanAndParse(text);

    if (parsed != null) {
      final homeState = ref.read(homeViewModelProvider);
      final reconciliation = scannerService.reconcile(parsed, homeState.obligations);
      HapticService.victoryPop();
      setState(() {
        _reconciliation = reconciliation;
        _isProcessing = false;
      });
    } else {
      setState(() {
        _reconciliation = null;
        _isProcessing = false;
      });
    }
  }

  Future<void> _commitReconciliation() async {
    final rec = _reconciliation;
    if (rec == null) return;

    final parsed = rec.parsed;

    if (rec.isUpdate && rec.matchedObligation != null) {
      final existing = rec.matchedObligation!;
      final updated = existing.copyWith(
        totalBalance: parsed.totalBalance,
        amount: parsed.monthlyAmount > 0 ? parsed.monthlyAmount : existing.amount,
        interestRate: parsed.interestRate > 0 ? parsed.interestRate : existing.interestRate,
        nextDueDate: parsed.dueDate != null
            ? drift.Value(parsed.dueDate)
            : (existing.nextDueDate != null ? drift.Value(existing.nextDueDate) : const drift.Value.absent()),
        updatedAt: DateTime.now(),
      );
      await ref.read(obligationRepositoryProvider).updateObligation(updated);
    } else {
      final now = DateTime.now();
      final companion = ObligationsCompanion.insert(
        title: parsed.title,
        amount: parsed.monthlyAmount > 0 ? parsed.monthlyAmount : (parsed.totalBalance / 12),
        totalBalance: drift.Value(parsed.totalBalance),
        interestRate: drift.Value(parsed.interestRate),
        startDate: parsed.dueDate ?? now,
        priority: parsed.priority,
        category: parsed.category,
        type: parsed.type,
        status: const drift.Value(ObligationStatus.pending),
        emiDurationMonths: drift.Value(parsed.emiDurationMonths ?? 12),
        nextDueDate: drift.Value(parsed.dueDate),
        gracePeriodDays: const drift.Value(0),
        emiPaidMonths: const drift.Value(0),
      );
      await ref.read(obligationRepositoryProvider).createObligation(companion);
    }

    HapticService.dopamineCascade();

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          rec.isUpdate
              ? '✨ Updated ${rec.matchedObligation!.title} balance to ₹${NumberFormat('#,##,###').format(rec.newBalance)}'
              : '🚀 Added new obligation: ${parsed.title}',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final currency = ref.watch(homeViewModelProvider).settings?.currency ?? '₹';
    final rec = _reconciliation;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101222) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.document_scanner_rounded, color: Color(0xFF6366F1), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Document & Statement Scanner',
                      style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '1-Snap on-device extraction from sanction letters & e-statements',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sample chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._sampleSnippets.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: isDark ? const Color(0xFF1E2136) : const Color(0xFFF1F5F9),
                      label: Text(
                        entry.key == 0
                            ? '📄 HDFC Loan Sanction'
                            : (entry.key == 1 ? '💳 SBI Credit Card' : '📱 Bajaj EMI Letter'),
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        HapticService.selection();
                        _textController.text = entry.value;
                        _processText(entry.value);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Input area
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  onChanged: _processText,
                  decoration: InputDecoration(
                    hintText: 'Paste or scan OCR text from your sanction letter, PDF, or SMS statement...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF16192A) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                ),

                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                if (rec != null) ...[
                  const SizedBox(height: 16),

                  // Reconciliation Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: rec.isUpdate
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: rec.isUpdate
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                            : const Color(0xFF10B981).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          rec.isUpdate ? Icons.sync_rounded : Icons.add_circle_outline_rounded,
                          color: rec.isUpdate ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec.isUpdate
                                    ? 'EXISTING OBLIGATION MATCHED'
                                    : 'NEW OBLIGATION DETECTED',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: rec.isUpdate ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rec.isUpdate
                                    ? 'Updating balance for ${rec.matchedObligation!.title}'
                                    : 'Will create new record: ${rec.parsed.title}',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (rec.isUpdate && rec.previousBalance != null)
                                Text(
                                  '$currency${rec.previousBalance!.toStringAsFixed(0)} ➔ $currency${rec.newBalance!.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Extracted details grid
                  _buildExtractedPills(rec.parsed, currency, isDark),
                ],
              ],
            ),
          ),

          // Commit button
          if (rec != null)
            ElevatedButton.icon(
              onPressed: _commitReconciliation,
              icon: Icon(
                rec.isUpdate ? Icons.check_circle_rounded : Icons.save_rounded,
                color: Colors.white,
              ),
              label: Text(
                rec.isUpdate
                    ? 'Confirm & Update Balance'
                    : 'Add To Duedo System',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: rec.isUpdate ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtractedPills(ParsedStatementResult parsed, String currency, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16192A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI PARSED ENTITIES',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(parsed.confidenceScore * 100).toInt()}% Match Confidence',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildEntityChip('Bank', parsed.detectedBankOrInstitution ?? 'Unknown'),
              _buildEntityChip('Principal', '$currency${parsed.totalBalance.toStringAsFixed(0)}'),
              _buildEntityChip('Monthly EMI', '$currency${parsed.monthlyAmount.toStringAsFixed(0)}'),
              _buildEntityChip('APR', '${parsed.interestRate.toStringAsFixed(1)}%'),
              if (parsed.dueDayOfMonth != null)
                _buildEntityChip('Due Day', '${parsed.dueDayOfMonth}th of month'),
              if (parsed.emiDurationMonths != null)
                _buildEntityChip('Tenure', '${parsed.emiDurationMonths} Months'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntityChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
