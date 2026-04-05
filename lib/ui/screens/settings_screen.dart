import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../viewmodels/home_viewmodel.dart';
import '../../services/database.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _incomeController = TextEditingController();
  final _paydayController = TextEditingController();
  String _selectedCurrency = '₹';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(homeViewModelProvider).settings;
      if (settings != null) {
        _incomeController.text = settings.monthlyIncome.toStringAsFixed(0);
        _paydayController.text = settings.paydayOfMonth.toString();
        setState(() {
          _selectedCurrency = settings.currency;
        });
      }
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _paydayController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    HapticService.success();
    final income = double.tryParse(_incomeController.text) ?? 0.0;
    final payday = int.tryParse(_paydayController.text) ?? 1;
    
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
          content: Text('Settings secure', style: TextStyle(fontWeight: FontWeight.bold)), 
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    title: 'Financial Profile',
                    description: 'Used for precise pressure calculations',
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _incomeController,
                          label: 'Monthly Net Income',
                          prefixText: '$_selectedCurrency ',
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _paydayController,
                          label: 'Payday (Day of Month, 1-31)',
                          icon: Icons.calendar_month_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionCard(
                    title: 'Display & Region',
                    description: 'Customize your visual experience',
                    child: _buildCurrencyPicker(),
                  ),
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
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? prefixText, IconData? icon}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        prefixText: prefixText,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary, size: 20) : null,
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 1)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.1)),
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
              color: isSelected ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1)),
              boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
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
}
