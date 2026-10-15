import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../services/financial_logic_service.dart';
import '../../services/haptic_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/upi_slay_modal.dart';

class FreedomTimeMachineScreen extends ConsumerStatefulWidget {
  const FreedomTimeMachineScreen({super.key});

  @override
  ConsumerState<FreedomTimeMachineScreen> createState() =>
      _FreedomTimeMachineScreenState();
}

class _FreedomTimeMachineScreenState
    extends ConsumerState<FreedomTimeMachineScreen> {
  int _selectedMonth = 0;
  final _financialLogic = FinancialLogicService();

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final currency = homeState.settings?.currency ?? '₹';
    final monthlyIncome = homeState.settings?.monthlyIncome ?? 50000.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snapshot = _financialLogic.calculateTimeMachineSnapshot(
      obligations: homeState.obligations,
      monthlyIncome: monthlyIncome,
      monthOffset: _selectedMonth,
    );

    final isOffenseMode = snapshot.isDebtFree;

    return Scaffold(
      backgroundColor: isOffenseMode
          ? (isDark ? const Color(0xFF041812) : const Color(0xFFE8F8F2))
          : (isDark ? const Color(0xFF0D0E15) : const Color(0xFFF8FAFC)),
      appBar: AppBar(
        title: Text(
          'Freedom Time Machine',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Banner (Defense vs Offense)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOffenseMode
                      ? [const Color(0xFF064E3B), const Color(0xFF047857)]
                      : [const Color(0xFF1E1B4B), const Color(0xFF311042)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isOffenseMode
                      ? const Color(0xFF10B981)
                      : const Color(0xFF818CF8).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: isOffenseMode
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOffenseMode
                              ? '⚡ OFFENSE MODE: WEALTH CREATOR'
                              : '🛡️ DEFENSE MODE: DEBT SLAYER',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM yyyy').format(snapshot.simulatedDate),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedMonth == 0
                        ? 'Today (Month 0)'
                        : '+$_selectedMonth Months Into The Future',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isOffenseMode
                        ? '🎉 DEBT ZERO ACHIEVED! All income converts directly into sovereign wealth.'
                        : 'Dragging forward simulates your snowball liquidation velocity.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tactile Scrub Slider Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161926) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TIMELINE SCRUBBER',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Month $_selectedMonth of 36',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isOffenseMode
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: isOffenseMode
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6366F1),
                      inactiveTrackColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                      thumbColor: isOffenseMode
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6366F1),
                      overlayColor: (isOffenseMode
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6366F1))
                          .withValues(alpha: 0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _selectedMonth.toDouble(),
                      min: 0,
                      max: 36,
                      divisions: 36,
                      label: 'Month $_selectedMonth',
                      onChanged: (val) {
                        final newMonth = val.round();
                        if (newMonth != _selectedMonth) {
                          HapticService.selection();
                          setState(() {
                            _selectedMonth = newMonth;
                          });
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickJumpButton('Today', 0),
                      _buildQuickJumpButton('6 Mo', 6),
                      _buildQuickJumpButton('12 Mo', 12),
                      _buildQuickJumpButton('24 Mo', 24),
                      _buildQuickJumpButton('36 Mo', 36),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Metric Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'DEBT REMAINING',
                    value: '$currency${NumberFormat.compact().format(snapshot.remainingDebtBalance)}',
                    subtext: snapshot.remainingDebtBalance == 0
                        ? '100% Cleared'
                        : '${((1 - snapshot.progressPercentage) * 100).toStringAsFixed(0)}% Left',
                    isPositive: snapshot.remainingDebtBalance == 0,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'CASHFLOW UNLOCKED',
                    value: '+$currency${NumberFormat.compact().format(snapshot.unlockedMonthlyCashflow)}/mo',
                    subtext: 'Reclaimed Monthly',
                    isPositive: snapshot.unlockedMonthlyCashflow > 0,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Slain Debts (Incinerated)
            if (snapshot.slainDebts.isNotEmpty) ...[
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'SLAIN DEBTS (${snapshot.slainDebts.length})',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$currency${snapshot.unlockedMonthlyCashflow.toStringAsFixed(0)}/mo Back',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...snapshot.slainDebts.map((ob) => _buildSlainDebtCard(ob, currency, isDark)),
              const SizedBox(height: 16),
            ],

            // Active / Remaining Debts
            if (snapshot.remainingDebts.isNotEmpty) ...[
              Row(
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'REMAINING OBLIGATIONS (${snapshot.remainingDebts.length})',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...snapshot.remainingDebts.map((ob) => _buildRemainingDebtCard(ob, currency, isDark)),
              const SizedBox(height: 20),
            ],

            // Snowflake Strike CTA
            if (homeState.obligations.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () {
                  HapticService.selection();
                  final highestPriority = homeState.obligations.firstWhere(
                    (o) => o.isActive && o.totalBalance > 0,
                    orElse: () => homeState.obligations.first,
                  );
                  UpiSlayModal.show(
                    context,
                    obligation: highestPriority,
                    currencyFormat: NumberFormat.simpleCurrency(name: currency, decimalDigits: 0),
                    isDark: isDark,
                  );
                },
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: Text(
                  'Accelerate With Snowflake Strike',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickJumpButton(String label, int month) {
    final isSelected = _selectedMonth == month;
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() {
          _selectedMonth = month;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required bool isPositive,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161926) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isPositive ? const Color(0xFF10B981) : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlainDebtCard(Obligation ob, String currency, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ob.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: TextDecoration.lineThrough,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                Text(
                  'Original Balance: $currency${ob.totalBalance > 0 ? ob.totalBalance.toStringAsFixed(0) : (ob.amount * 12).toStringAsFixed(0)}',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$currency${ob.amount.toStringAsFixed(0)}/mo',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingDebtCard(Obligation ob, String currency, bool isDark) {
    final balance = ob.totalBalance > 0 ? ob.totalBalance : (ob.amount * 12.0);
    final monthlyPayment = ob.amount > 0 ? ob.amount : 1000.0;
    final projectedRemaining = (balance - (monthlyPayment * _selectedMonth)).clamp(0.0, balance);
    final progress = balance > 0 ? ((balance - projectedRemaining) / balance).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161926) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ob.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$currency${projectedRemaining.toStringAsFixed(0)} left',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: const Color(0xFFF43F5E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
