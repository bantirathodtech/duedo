import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' as drift;

import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../viewmodels/home_viewmodel.dart';
import '../../services/database.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import 'settings_screen.dart';

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
  final _screenshotController = ScreenshotController();

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                            onPressed: () {
                              HapticService.selection();
                              Navigator.pop(context);
                            },
                          )
                        else
                          const SizedBox.shrink(),
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, size: 22),
                          tooltip: 'Advanced Settings',
                          onPressed: () {
                            HapticService.selection();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Profile & Baseline', style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                    const SizedBox(height: 6),
                    Text(
                      'Configure baseline income, currency, theme and personal financial preferences.',
                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildSocialMasteryCard(state),
                    
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

                    const SizedBox(height: 48),
                    _buildSaveButton(),
                    const SizedBox(height: 36),
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/brand/horizontal_lockup.png',
                            height: 38,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sovereign Financial Operating System • v2.4.0',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
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
            Expanded(
              child: Text(
                title, 
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
        Expanded(
          child: Text(
            title, 
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
                Expanded(
                  child: Text(
                    'Day of Month', 
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$_payday${_getDaySuffix(_payday)}', 
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.primary.withValues(alpha: 0.1),
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withValues(alpha: 0.2),
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
            BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
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

  Widget _buildSocialMasteryCard(HomeState state) {
    if (state.isLoading) return const SizedBox();
    
    final notifier = ref.read(homeViewModelProvider.notifier);
    final rank = notifier.financialRank;
    final id = notifier.anonymousUserId;

    return Screenshot(
      controller: _screenshotController,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration(context).copyWith(
          gradient: LinearGradient(
            colors: [AppTheme.primary.withValues(alpha: 0.2), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/brand/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ANONYMOUS GLOBAL ID', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                        Text(id, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    rank,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SOCIAL STANDING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('Global Elite Financial Class', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _shareSuccessCard,
                  icon: const Icon(Icons.share_rounded, color: AppTheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareSuccessCard() async {
    HapticService.success();
    final notifier = ref.read(homeViewModelProvider.notifier);
    final rank = notifier.financialRank;
    
    final image = await _screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/duedo_rank.png').create();
      await imagePath.writeAsBytes(image);
      
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'I\'m in the $rank of the world\'s financially disciplined on Duedo. 🚀 #FinancialFreedom #Duedo',
      );
    }
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
