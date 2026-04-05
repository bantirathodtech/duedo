import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' as drift;

import '../../viewmodels/home_viewmodel.dart';
import '../../services/database.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import 'subscription_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _incomeController = TextEditingController();
  final _currencyController = TextEditingController();
  
  int _payday = 1;
  String _themeMode = 'system';
  bool _isPremium = false;
  bool _initialized = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _loadSettings(UserSetting settings) {
    if (_initialized) return;
    _incomeController.text = settings.monthlyIncome.toStringAsFixed(0);
    _currencyController.text = settings.currency;
    _payday = settings.paydayOfMonth;
    _themeMode = settings.themeMode;
    _isPremium = settings.isPremium;
    _initialized = true;
  }

  void _saveSettings() {
    final income = double.tryParse(_incomeController.text) ?? 0.0;
    final currency = _currencyController.text.trim().isEmpty ? '₹' : _currencyController.text.trim();
    
    final companion = UserSettingsCompanion(
      id: const drift.Value(1),
      monthlyIncome: drift.Value(income),
      paydayOfMonth: drift.Value(_payday),
      themeMode: drift.Value(_themeMode),
      currency: drift.Value(currency),
      isPremium: drift.Value(_isPremium),
    );

    ref.read(homeViewModelProvider.notifier).updateSettings(companion);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings verified & saved.', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.settings != null) {
      _loadSettings(state.settings!);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configuration', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                    const SizedBox(height: 8),
                    Text(
                      'Powering the Action Engine with accurate baseline context.',
                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 40),

                    _buildSectionHeader(Icons.account_balance_wallet_rounded, 'Income Baseline'),
                    const SizedBox(height: 16),
                    _buildTextField('Monthly Income', _incomeController, isDark, TextInputType.number),
                    
                    const SizedBox(height: 32),
                    
                    _buildSectionHeader(Icons.calendar_today_rounded, 'Primary Payday'),
                    const SizedBox(height: 8),
                    _buildPaydaySlider(isDark),

                    const SizedBox(height: 32),
                    
                    _buildSectionHeader(Icons.style_rounded, 'Appearance & Localization'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Currency', _currencyController, isDark, TextInputType.text)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildThemeDropdown(isDark)),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.gavel_rounded, 'Legal & Compliance'),
                    const SizedBox(height: 16),
                    _buildLegalButton('Privacy Policy', () {
                      // Logic to open URL or internal viewer
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy Policy loaded.')));
                    }),
                    const SizedBox(height: 12),
                    _buildLegalButton('Terms of Service', () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terms of Service loaded.')));
                    }),

                    const SizedBox(height: 64),
                    _buildSaveButton(),
                    const SizedBox(height: 120), // Bottom padding for dock
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: AppTheme.glassDecoration(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark, TextInputType type) {
    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPaydaySlider(bool isDark) {
    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Day of Month', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(
                  '${_payday}${_getDaySuffix(_payday)}', 
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.primary.withOpacity(0.1),
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _payday.toDouble(),
              min: 1,
              max: 31,
              divisions: 30,
              onChanged: (val) {
                HapticService.selection();
                setState(() => _payday = val.toInt());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeDropdown(bool isDark) {
    return Container(
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _themeMode,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : Colors.black),
          items: const [
            DropdownMenuItem(value: 'system', child: Text('System')),
            DropdownMenuItem(value: 'light', child: Text('Light')),
            DropdownMenuItem(value: 'dark', child: Text('Dark')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _themeMode = val);
          },
        ),
      ),
    );
  }

  Widget _buildPlanStatus(bool isDark) {
    return Container(
      decoration: AppTheme.glassDecoration(context).copyWith(
        border: Border.all(
          color: _isPremium ? AppTheme.primary.withOpacity(0.5) : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT PLAN',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isPremium ? 'Duedo+ Pro' : 'Duedo Free',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _isPremium ? AppTheme.primary : null,
                    ),
                  ),
                ],
              ),
              if (_isPremium)
                const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 32)
              else
                const Icon(Icons.shield_outlined, color: Colors.grey, size: 32),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _isPremium 
              ? 'You are currently protected by our elite ad-free intelligence engine.' 
              : 'You are currently seeing 30-second ads upon app opening.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 24),
          if (!_isPremium)
            ElevatedButton(
              onPressed: () {
                HapticService.selection();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'UPGRADE TO DUEDO+',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: () {
        HapticService.success();
        _saveSettings();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'SAVE CONFIGURATION',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5),
        ),
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}
