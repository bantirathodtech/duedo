import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../viewmodels/home_viewmodel.dart';
import '../../services/database.dart';
import '../../models/app_enums.dart';
import '../../services/haptic_service.dart';

/// 🚀 30-Second Quick Ignition Modal
/// Allows new users to instantly initialize their financial command deck:
/// Either through a streamlined 2-step setup or a 1-tap "Explore Demo Fleet" ignition.
class QuickIgnitionModal extends StatefulWidget {
  final HomeViewModel viewModel;
  final NumberFormat currencyFormat;
  final bool isDark;

  const QuickIgnitionModal({
    super.key,
    required this.viewModel,
    required this.currencyFormat,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required HomeViewModel viewModel,
    required NumberFormat currencyFormat,
    required bool isDark,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0D111D) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => QuickIgnitionModal(
        viewModel: viewModel,
        currencyFormat: currencyFormat,
        isDark: isDark,
      ),
    );
  }

  @override
  State<QuickIgnitionModal> createState() => _QuickIgnitionModalState();
}

class _QuickIgnitionModalState extends State<QuickIgnitionModal> {
  int _currentStep = 0; // 0 = Income & Payday, 1 = Primary Target
  bool _isLoading = false;

  // Step 1 Controllers
  final _incomeController = TextEditingController(text: '75000');
  int _selectedPayday = 1;

  // Step 2 Controllers
  final _titleController = TextEditingController(text: 'Primary Credit Card');
  final _balanceController = TextEditingController(text: '45000');
  final _emiController = TextEditingController(text: '4500');
  final _aprController = TextEditingController(text: '24.0');
  final String _selectedCategory = 'Credit Card';

  @override
  void dispose() {
    _incomeController.dispose();
    _titleController.dispose();
    _balanceController.dispose();
    _emiController.dispose();
    _aprController.dispose();
    super.dispose();
  }

  Future<void> _igniteCustomFleet() async {
    final income = double.tryParse(_incomeController.text.trim()) ?? 50000;
    final balance = double.tryParse(_balanceController.text.trim()) ?? 25000;
    final emi = double.tryParse(_emiController.text.trim()) ?? 2500;
    final apr = double.tryParse(_aprController.text.trim()) ?? 18.0;
    final title = _titleController.text.trim().isEmpty ? 'Primary Debt' : _titleController.text.trim();

    setState(() => _isLoading = true);
    HapticService.heavyImpact();

    try {
      // 1. Update user settings
      await widget.viewModel.updateSettings(
        UserSettingsCompanion(
          monthlyIncome: drift.Value(income),
          paydayOfMonth: drift.Value(_selectedPayday),
        ),
      );

      // 2. Add primary obligation
      final now = DateTime.now();
      await widget.viewModel.addObligation(
        ObligationsCompanion(
          title: drift.Value(title),
          type: const drift.Value(ObligationType.emi),
          amount: drift.Value(emi),
          totalBalance: drift.Value(balance),
          interestRate: drift.Value(apr),
          priority: const drift.Value(PriorityLevel.high),
          category: drift.Value(_selectedCategory),
          startDate: drift.Value(now),
          nextDueDate: drift.Value(DateTime(now.year, now.month, now.day + 7)),
          isActive: const drift.Value(true),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🚀', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Sovereign Instruments Ignited!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00D09C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ignite: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadDemoFleet() async {
    setState(() => _isLoading = true);
    HapticService.heavyImpact();
    await widget.viewModel.seedDemoFleet();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Demo Fleet Activated! Full Instruments Live.',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF6366F1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D09C), Color(0xFF38BDF8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '30-Second Quick Ignition',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Step ${_currentStep + 1} of 2 • Activate Financial Radar',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Instant Demo Fleet Card (One-Tap Exploration)
          GestureDetector(
            onTap: _isLoading ? null : _loadDemoFleet,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDark
                      ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                      : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: Color(0xFF818CF8), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore with Full Demo Fleet',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Instant test data to view Sankey River, ECG Wave & Velocity Radar',
                          style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF818CF8)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Step Content
          if (_currentStep == 0) _buildStep1Income() else _buildStep2Obligation(),

          const SizedBox(height: 24),

          // Bottom Action Buttons
          Row(
            children: [
              if (_currentStep > 0) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_currentStep == 0) {
                            HapticService.selection();
                            setState(() => _currentStep = 1);
                          } else {
                            _igniteCustomFleet();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09C),
                    foregroundColor: const Color(0xFF092C22),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF092C22)),
                        )
                      : Text(
                          _currentStep == 0 ? 'Next: Add Target Debt ➔' : '🚀 Ignite Instruments',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Income() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONTHLY FUEL (INCOME)',
          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF00D09C)),
            hintText: '50000',
            filled: true,
            fillColor: widget.isDark ? const Color(0xFF161B2B) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SALARY PAYDAY OF MONTH',
          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1, 5, 10, 25, 28].map((day) {
            final isSelected = _selectedPayday == day;
            return ChoiceChip(
              label: Text('${day}th of month'),
              selected: isSelected,
              onSelected: (_) {
                HapticService.selection();
                setState(() => _selectedPayday = day);
              },
              selectedColor: const Color(0xFF00D09C).withValues(alpha: 0.2),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF00D09C) : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Obligation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIMARY DEBT / EMI TO SLAY',
          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'e.g. HDFC Credit Card, Personal Loan',
            filled: true,
            fillColor: widget.isDark ? const Color(0xFF161B2B) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL BALANCE',
                    style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _balanceController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      filled: true,
                      fillColor: widget.isDark ? const Color(0xFF161B2B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTHLY EMI',
                    style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emiController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      filled: true,
                      fillColor: widget.isDark ? const Color(0xFF161B2B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APR %',
                    style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _aprController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.isDark ? const Color(0xFF161B2B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
