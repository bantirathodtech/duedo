import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../services/database.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../../repositories/obligation_repository.dart';
import '../../models/app_enums.dart';
import '../../services/vault_service.dart';
import '../../services/supabase_service.dart';
import '../../services/freedom_pact_service.dart';
import '../../services/execudo_bridge_service.dart';
import 'freedom_pact_screen.dart';
import 'package:intl/intl.dart';
import 'freedom_league_screen.dart';
import '../widgets/glance_widget_preview.dart';
import '../../services/financial_logic_service.dart';
import '../../services/freedom_league_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _incomeController;
  late TextEditingController _paydayController;
  String _selectedCurrency = '₹';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(homeViewModelProvider).settings;
    _incomeController = TextEditingController(text: settings?.monthlyIncome.toStringAsFixed(0) ?? '0');
    _paydayController = TextEditingController(text: settings?.paydayOfMonth.toString() ?? '1');
    _selectedCurrency = settings?.currency ?? '₹';
    _loadVaultStatus();

    // Real-time updates for the "True Disposable Income" card
    _incomeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  bool _vaultEnabled = false;
  void _loadVaultStatus() async {
    final enabled = await ref.read(vaultServiceProvider).isVaultEnabled();
    if (mounted) setState(() => _vaultEnabled = enabled);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _paydayController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    final incomeStr = _incomeController.text.trim();
    final paydayStr = _paydayController.text.trim();

    if (incomeStr.isEmpty) {
      _showError('Please enter your monthly income');
      return;
    }

    final income = double.tryParse(incomeStr) ?? -1;
    if (income < 0) {
      _showError('Please enter a valid positive income');
      return;
    }

    final payday = int.tryParse(paydayStr) ?? -1;
    if (payday < 1 || payday > 31) {
      _showError('Payday must be between 1 and 31');
      return;
    }

    HapticService.success();
    await ref.read(homeViewModelProvider.notifier).updateSettings(
      UserSettingsCompanion(
        id: const drift.Value(1),
        monthlyIncome: drift.Value(income),
        currency: drift.Value(_selectedCurrency),
        paydayOfMonth: drift.Value(payday),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Financial profile updated', style: TextStyle(fontWeight: FontWeight.bold)), 
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String message) {
    HapticService.warning();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addRecurring() {
    String title = '';
    double amount = 0;
    String? taxCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Compulsory Payment', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Rent, Insurance, PF, utilities, etc.', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(
              decoration: _inputDecoration('Expense Name (e.g. Rent)'),
              onChanged: (v) => title = v,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: _inputDecoration('Monthly Amount'),
              keyboardType: TextInputType.number,
              onChanged: (v) => amount = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1E1E1E),
              decoration: _inputDecoration('🇮🇳 Tax Category (Optional)'),
              items: const [
                DropdownMenuItem(value: null, child: Text('None', style: TextStyle(color: Colors.grey))),
                DropdownMenuItem(value: '80C', child: Text('80C (LIC, PF, ELSS)', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: '80D', child: Text('80D (Health Insurance)', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) => taxCategory = v,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  if (title.isNotEmpty && amount > 0) {
                    final repo = ref.read(obligationRepositoryProvider);
                    await repo.createObligation(ObligationsCompanion(
                      title: drift.Value(title),
                      amount: drift.Value(amount),
                      type: const drift.Value(ObligationType.recurring),
                      startDate: drift.Value(DateTime.now()),
                      category: const drift.Value('Fixed'),
                      priority: const drift.Value(PriorityLevel.high),
                      totalBalance: drift.Value(amount),
                      taxCategory: drift.Value(taxCategory),
                    ));
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    HapticService.success();
                  }
                },
                style: _primaryButtonStyle(),
                child: const Text('Add to Planner'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('FINANCIAL PLANNER'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          AppTheme.glassBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: '1. Total Income',
                    description: 'Enter your monthly in-hand salary',
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _incomeController,
                          label: 'Monthly Net Income',
                          prefixText: '$_selectedCurrency ',
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: '2. Compulsory Payments',
                    description: 'Rent, Insurance, PF, and Living Expenses',
                    child: Column(
                      children: [
                        _buildRecurringList(),
                        const SizedBox(height: 16),
                        _buildAddRecurringButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDisposableIncomeCard(),
                  const SizedBox(height: 32),
                  _buildSectionCard(
                    title: 'General Preferences',
                    description: 'Customize notifications and currency',
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _paydayController,
                          label: 'Payday (Day of Month, 1-31)',
                          icon: Icons.calendar_month_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildCurrencyPicker(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: '🛡️ Security Vault',
                    description: 'Lock your financial data behind biometrics',
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Biometric App Lock',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Use FaceID/Fingerprint to open Duedo',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      value: _vaultEnabled,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (val) async {
                        final service = ref.read(vaultServiceProvider);
                        if (val) {
                          final success = await service.authenticate(reason: 'Enable Vault security');
                          if (success) {
                            await service.setVaultEnabled(true);
                            setState(() => _vaultEnabled = true);
                          }
                        } else {
                          final success = await service.authenticate(reason: 'Disable Vault security');
                          if (success) {
                            await service.setVaultEnabled(false);
                            setState(() => _vaultEnabled = false);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                   _buildSectionCard(
                    title: '🤖 Automator (SMS Sync)',
                    description: 'Auto-detect EMI payments from Bank SMS',
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Enable Automated Sync',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Supports HDFC, SBI, ICICI, etc.',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      value: ref.watch(homeViewModelProvider).settings?.smsSyncEnabled ?? false,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (val) async {
                        HapticService.selection();
                        await ref.read(homeViewModelProvider.notifier).updateSettings(
                          UserSettingsCompanion(
                            id: const drift.Value(1),
                            smsSyncEnabled: drift.Value(val),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFreedomPactSection(),
                  const SizedBox(height: 24),
                  _buildExecudoBridgeSection(),
                  const SizedBox(height: 24),
                  _buildPersonaVoiceSection(),
                  const SizedBox(height: 24),
                  _buildFreedomLeagueSection(),
                  const SizedBox(height: 24),
                  _buildGlanceWidgetSection(),
                  const SizedBox(height: 24),
                  _buildCloudSyncSection(),
                  const SizedBox(height: 60),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String description, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      ),
    );
  }

  Widget _buildCurrencyPicker() {
    final currencies = ['₹', '\$', '€', '£', '¥'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: currencies.map((c) {
        final isSelected = _selectedCurrency == c;
        return GestureDetector(
          onTap: () {
            HapticService.selection();
            setState(() => _selectedCurrency = c);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
              boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
            ),
            child: Text(
              c,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecurringList() {
    final state = ref.watch(homeViewModelProvider);
    final recurring = state.obligations.where((o) => o.type == ObligationType.recurring && o.isActive).toList();

    if (recurring.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(12)),
        child: const Text('No compulsory payments added yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    return Column(
      children: recurring.map((ob) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(ob.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                   if (ob.taxCategory != null)
                     Container(
                       margin: const EdgeInsets.only(top: 4),
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                       child: Text(ob.taxCategory!, style: const TextStyle(color: AppTheme.success, fontSize: 9, fontWeight: FontWeight.bold)),
                     ),
                 ],
               ),
             ),
             Text('$_selectedCurrency ${ob.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900)),
             const SizedBox(width: 8),
             IconButton(
               icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
               onPressed: () {
                 HapticService.warning();
                 ref.read(obligationRepositoryProvider).deleteObligation(ob.id);
               },
             ),
           ],
         ),
       )).toList(),
     );
   }

  Widget _buildAddRecurringButton() {
    return GestureDetector(
      onTap: _addRecurring,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 18),
            SizedBox(width: 8),
            Text('Add Compulsory Payment', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDisposableIncomeCard() {
    final state = ref.watch(homeViewModelProvider);
    final income = double.tryParse(_incomeController.text) ?? (state.settings?.monthlyIncome ?? 0.0);
    final recurringTotal = state.totalMonthlyRecurring;
    final disposable = income - recurringTotal;

    return Container(
      decoration: BoxDecoration(
        color: disposable > 0 ? AppTheme.primary.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (disposable > 0 ? AppTheme.primary : Colors.red).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRUE DISPOSABLE INCOME', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 4),
              Text('Available for debt & goals', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ],
          ),
          Text(
            '$_selectedCurrency ${disposable.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 24, 
              fontWeight: FontWeight.w900, 
              color: disposable > 0 ? Colors.white : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
    );
  }

  static ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    );
  }

  Widget _buildPersonaVoiceSection() {
    final settings = ref.watch(homeViewModelProvider).settings;
    final isSavage = settings?.isSavageMode ?? false;

    return _buildSectionCard(
      title: '🎭 AI Financial Persona',
      description: 'Select how Duedo coaches, reminds, and celebrates with you',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPersonaCard(
                  title: 'Zen Monk',
                  tag: 'MINDFUL',
                  description: 'Calm, stoic, breathing room, non-judgmental guidance',
                  quote: '"Peace of mind is true wealth."',
                  icon: Icons.spa_rounded,
                  color: const Color(0xFF00D09C),
                  isSelected: !isSavage,
                  onTap: () async {
                    HapticService.selection();
                    await ref.read(homeViewModelProvider.notifier).updateSettings(
                      const UserSettingsCompanion(
                        id: drift.Value(1),
                        isSavageMode: drift.Value(false),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPersonaCard(
                  title: 'Savage Roaster',
                  tag: 'CRED / CLEO',
                  description: 'Witty tough love, hilarious roasts, and high-energy hype',
                  quote: '"Punch interest in the teeth."',
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF4D4D),
                  isSelected: isSavage,
                  onTap: () async {
                    HapticService.savageThud();
                    await ref.read(homeViewModelProvider.notifier).updateSettings(
                      const UserSettingsCompanion(
                        id: drift.Value(1),
                        isSavageMode: drift.Value(true),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreedomLeagueSection() {
    final league = ref.watch(freedomLeagueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildSectionCard(
      title: '🏆 Freedom Arena (Leagues)',
      description: 'Anonymous Duolingo-style weekly discipline cohorts',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161928) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD946EF).withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(league.currentTier.trophyEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${league.currentTier.displayName} • Rank #${league.userRank}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      Text(
                        '${league.userPoints} Discipline Points • ${league.daysRemainingInSeason} days left in season',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.leaderboard_rounded, size: 16),
                label: const Text('Enter Freedom Arena', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD946EF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  HapticService.selection();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FreedomLeagueScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlanceWidgetSection() {
    final state = ref.watch(homeViewModelProvider);
    final currency = state.settings?.currency ?? '₹';
    final format = NumberFormat.simpleCurrency(name: currency, decimalDigits: 0);
    final logic = FinancialLogicService();
    final safeToSpend = logic.calculateSafeToSpend(
      obligations: state.obligations,
      monthlyIncome: state.settings?.monthlyIncome ?? 50000.0,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildSectionCard(
      title: '📱 Ambient Lock-Screen Glance',
      description: 'Pin live Safe-to-Spend & rings on your phone lock screen',
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.widgets_rounded, color: Color(0xFF3B82F6), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Hardware Layer Glance',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(
                      'Ambient updates with zero manual app opens',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.phone_android_rounded, size: 16),
              label: const Text('Preview & Sync Lock Screen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6), width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                GlanceWidgetPreviewModal.show(
                  context,
                  safeToSpendAmount: safeToSpend.dailyAmount,
                  cleanDayCompleted: true,
                  streakDays: state.settings?.paymentStreak ?? 5,
                  ringsClosed: false,
                  currencyFormat: format,
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaCard({
    required String title,
    required String tag,
    required String description,
    required String quote,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? color : Colors.white,
              ),
            ),
            Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isSelected ? color.withValues(alpha: 0.8) : Colors.white38,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white60,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudSyncSection() {
    final supabaseService = ref.read(supabaseServiceProvider);
    final isAuth = supabaseService.isAuthenticated;
    final user = supabaseService.currentUser;

    return _buildSectionCard(
      title: '🌐 Cloud Sync & Account',
      description: 'Sync your data across all devices',
      child: Column(
        children: [
          if (isAuth) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppTheme.primary),
              ),
              title: Text(user?.email ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Account linked & syncing', style: TextStyle(color: AppTheme.success, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.grey),
                onPressed: () async {
                  HapticService.warning();
                  await supabaseService.signOut();
                  // Trigger UI refresh
                  setState(() {});
                },
              ),
            ),
          ] else ...[
            const Text(
              'Currently in Guest Mode (Offline). Sign in to back up your debts and access them anywhere.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Sync with Google Account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  try {
                    HapticService.selection();
                    await supabaseService.signInWithGoogle();
                    
                    if (mounted) {
                      // Trigger migration
                      final repo = ref.read(obligationRepositoryProvider);
                      await repo.syncAllLocalToCloud();
                      
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cloud sync activated! Data migrated.')),
                      );
                      setState(() {});
                    }
                  } catch (e) {
                    _showError('Sync failed: $e');
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFreedomPactSection() {
    final pactState = ref.watch(freedomPactServiceProvider);
    final pactNotifier = ref.read(freedomPactServiceProvider.notifier);

    return _buildSectionCard(
      title: '🤝 Freedom Pact',
      description: 'Tackle debt together with your spouse or co-borrower',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (pactState.isPaired ? AppTheme.success : AppTheme.primary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pactState.isPaired ? '🟢 PACT ACTIVE' : '⚡ ANONYMOUS CO-BORROWER SYNC',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: pactState.isPaired ? AppTheme.success : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!pactState.isPaired) ...[
            Text(
              'Pair devices using an anonymous sync code. Share aggregate debt-freedom timelines and compound savings without exposing sensitive account numbers.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR ANONYMOUS PACT CODE',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pactState.myPactCode,
                          style: GoogleFonts.firaCode(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () {
                      HapticService.selection();
                      Clipboard.setData(ClipboardData(text: pactState.myPactCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pact code copied to clipboard! Share it with your partner.'),
                          backgroundColor: AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.link_rounded, size: 18),
                label: const Text('Pair With Partner Device', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => _showPairPactModal(pactNotifier),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.success.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          pactState.partnerName,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pactState.partnerCode ?? 'PAIRED',
                          style: GoogleFonts.firaCode(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PARTNER DEBT', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                            const SizedBox(height: 2),
                            Text(
                              '$_selectedCurrency ${pactState.partnerTotalDebt.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SNOWFLAKES KILLED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                            const SizedBox(height: 2),
                            Text(
                              '$_selectedCurrency ${pactState.partnerSnowflakesSaved.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: pactState.isSyncing 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: Text(pactState.isSyncing ? 'Syncing...' : 'Sync Vault Now'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: pactState.isSyncing ? null : () async {
                      HapticService.selection();
                      await pactNotifier.syncNow();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Freedom Pact vault synced!'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'Unlink Pact',
                  icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () async {
                    HapticService.warning();
                    await pactNotifier.unlinkPact();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Freedom Pact unlinked'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Open Full Freedom Chamber', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                HapticService.selection();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FreedomPactScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPairPactModal(FreedomPactNotifier notifier) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: 'Partner Device');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connect Freedom Pact', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              'Enter your partner\'s 6-character anonymous code (e.g. PACT-849201).',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration('Partner\'s Pact Code (e.g. PACT-394821)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: _inputDecoration('Partner Nickname (e.g. Spouse, Sarah)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: _primaryButtonStyle(),
                onPressed: () async {
                  final code = codeCtrl.text.trim();
                  if (code.isEmpty) return;
                  final ok = await notifier.pairWithCode(code, name: nameCtrl.text.trim().isEmpty ? 'Partner Device' : nameCtrl.text.trim());
                  if (!ctx.mounted || !mounted) return;
                  Navigator.pop(ctx);
                  if (ok) {
                    HapticService.success();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Freedom Pact linked successfully!'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
                    );
                  } else {
                    _showError('Invalid code or cannot pair with your own code');
                  }
                },
                child: const Text('Establish Freedom Pact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExecudoBridgeSection() {
    final execudoState = ref.watch(execudoBridgeServiceProvider);
    final execudoNotifier = ref.read(execudoBridgeServiceProvider.notifier);

    return _buildSectionCard(
      title: '⚡ Execudo Focus Bridge',
      description: 'Link deep execution discipline to eliminate impulse spending',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AVISHIO ECOSYSTEM LINK',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: const Color(0xFF818CF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Sync with Execudo Work Engine',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Connects daily deep focus blocks to prevent impulsive debt purchases.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            value: execudoState.isConnected,
            activeTrackColor: const Color(0xFF6366F1),
            onChanged: (val) async {
              HapticService.selection();
              await execudoNotifier.setConnected(val);
            },
          ),
          if (execudoState.isConnected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Color(0xFF818CF8), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'DISCIPLINE MULTIPLIER ACTIVE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF818CF8),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FOCUS STREAK', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                            const SizedBox(height: 2),
                            Text(
                              '🔥 ${execudoState.deepFocusStreakDays} Days',
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('IMPULSE DEFICIT SAVED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                            const SizedBox(height: 2),
                            Text(
                              '🛡️ $_selectedCurrency ${execudoState.impulseSavingsGenerated.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: _primaryButtonStyle(),
        child: const Text('Save Financial Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
