import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../models/app_enums.dart';
import '../../services/database.dart';
import '../../repositories/obligation_repository.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads/ad_service.dart';
import '../../services/statement_parser_service.dart';

class AddObligationScreen extends ConsumerStatefulWidget {
  final Obligation? obligation;
  const AddObligationScreen({super.key, this.obligation});

  @override
  ConsumerState<AddObligationScreen> createState() => _AddObligationScreenState();
}

class _AddObligationScreenState extends ConsumerState<AddObligationScreen> {
  final _formKey = GlobalKey<FormState>();
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  
  // Controllers for zero-typing programmatic auto-fill
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _totalBalanceController;
  late TextEditingController _interestRateController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;

  // Form Fields
  late String _title;
  late double _amount;
  late ObligationType _type;
  late PriorityLevel _priority;
  late String _category;
  late DateTime _startDate;
  late int? _emiDuration;
  late int _gracePeriodDays;
  late double _totalBalance;
  late double _interestRate;
  late String? _notes;
  bool _noDueDate = false;

  @override
  void initState() {
    super.initState();
    final o = widget.obligation;
    _title = o?.title ?? '';
    _amount = o?.amount ?? 0;
    _type = o?.type ?? ObligationType.oneTime;
    _priority = o?.priority ?? PriorityLevel.medium;
    _category = o?.category ?? 'General';
    _startDate = o?.startDate ?? DateTime.now();
    _emiDuration = o?.emiDurationMonths;
    _gracePeriodDays = o?.gracePeriodDays ?? 0;
    _totalBalance = o?.totalBalance ?? 0;
    _interestRate = o?.interestRate ?? 0;
    _notes = o?.notes;

    _titleController = TextEditingController(text: _title);
    _amountController = TextEditingController(text: _amount > 0 ? _amount.toStringAsFixed(0) : '');
    _totalBalanceController = TextEditingController(text: _totalBalance > 0 ? _totalBalance.toStringAsFixed(0) : '0');
    _interestRateController = TextEditingController(text: _interestRate > 0 ? _interestRate.toString() : '0');
    _durationController = TextEditingController(text: _emiDuration != null ? _emiDuration.toString() : '');
    _notesController = TextEditingController(text: _notes ?? '');

    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId ?? '',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _totalBalanceController.dispose();
    _interestRateController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  static const List<String> _categories = [
    'Bills', 'EMI', 'Rent', 'Investment', 'Entertainment', 'Health', 
    'Subscription', 'Grocery', 'Shopping', 'Travel', 'General', 'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.obligation == null ? 'New Obligation' : 'Edit Obligation',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.obligation != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
            ),
        ],
      ),
      body: Stack(
        children: [
          AppTheme.glassBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.obligation == null) ...[
                      _buildSmartParserBanner(),
                      const SizedBox(height: 20),
                    ],
                    _StaggeredEntry(
                      delay: 0,
                      child: _buildSectionCard(
                        title: 'Basic Info',
                        child: Column(
                          children: [
                            _buildTypeSelector(),
                            const SizedBox(height: 24),
                            _buildTextField('Title', (v) => _title = v, icon: Icons.title_rounded, controller: _titleController),
                            const SizedBox(height: 16),
                            _buildAmountField(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _StaggeredEntry(
                      delay: 100,
                      child: _buildSectionCard(
                        title: 'Classification',
                        child: Column(
                          children: [
                            _buildPriorityDropdown(),
                            const SizedBox(height: 16),
                            _buildCategoryDropdown(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _StaggeredEntry(
                      delay: 200,
                      child: _buildSectionCard(
                        title: 'Schedule & Timing',
                        child: Column(
                          children: [
                            if (_type == ObligationType.oneTime) ...[
                              _buildMustPayToggle(),
                              const SizedBox(height: 16),
                            ],
                            if (!_noDueDate || _type == ObligationType.emi) _buildDatePicker(context),
                            if (_type == ObligationType.emi) ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                'Duration (Months)', 
                                (v) => _emiDuration = int.tryParse(v), 
                                keyboardType: TextInputType.number,
                                icon: Icons.calendar_month_rounded,
                                controller: _durationController,
                              ),
                              const SizedBox(height: 16),
                              _buildPaymentWindowSlider(),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Total Balance', 
                                    (v) => _totalBalance = double.tryParse(v) ?? 0, 
                                    keyboardType: TextInputType.number,
                                    icon: Icons.account_balance_wallet_rounded,
                                    controller: _totalBalanceController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    'Interest Rate (%)', 
                                    (v) => _interestRate = double.tryParse(v) ?? 0, 
                                    keyboardType: TextInputType.number,
                                    icon: Icons.percent_rounded,
                                    controller: _interestRateController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _StaggeredEntry(
                      delay: 300,
                      child: _buildSectionCard(
                        title: 'Additional Details',
                        child: _buildTextField(
                          'Notes (Optional)', 
                          (v) => _notes = v, 
                          maxLines: 3, 
                          icon: Icons.notes_rounded,
                          controller: _notesController,
                        ),
                      ),
                    ),
                    if (widget.obligation != null) ...[
                      const SizedBox(height: 20),
                      _StaggeredEntry(delay: 350, child: _buildPaymentSummary()),
                    ],
                    const SizedBox(height: 40),
                    _StaggeredEntry(delay: 400, child: _buildSubmitButton()),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.glassDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppTheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMustPayToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: const Text('No Specific Due Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: const Text('Marks as a high-priority "Must Pay" item', style: TextStyle(fontSize: 11)),
        value: _noDueDate,
        activeThumbColor: AppTheme.primary,
        onChanged: (v) {
          HapticService.selection();
          setState(() {
            _noDueDate = v;
            if (v) {
              _startDate = DateTime.now();
              _priority = PriorityLevel.high;
            }
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final totalPaid = viewModel.getTotalPaid(widget.obligation!.id);
    final remaining = _amount - totalPaid;
    
    final payments = state.payments.where((p) => p.obligationId == widget.obligation!.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Expanded(child: _buildSummaryItem('Total Paid', '₹${totalPaid.toInt()}', AppTheme.primary)),
                   const SizedBox(width: 8),
                   Expanded(child: _buildSummaryItem('Remaining', '₹${remaining.toInt()}', AppTheme.danger)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(remaining),
                  icon: const Icon(Icons.add_card, size: 18),
                  label: const Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (payments.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Payment History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...payments.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: AppTheme.primary.withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '₹${p.amountPaid.toInt()} on ${DateFormat('MMM dd').format(p.paidDate)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (p.note != null) 
                  Flexible(
                    child: Text(
                      p.note!, 
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  void _showPaymentDialog(double suggestedAmount) {
    final controller = TextEditingController(text: suggestedAmount.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount Paid', prefixText: '₹ '),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                await ref.read(homeViewModelProvider.notifier).recordPayment(widget.obligation!, amount);
                if (!context.mounted) return;
                Navigator.pop(context);
                setState(() {}); // Rebuild to show updated summary
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              title: 'One-time',
              isSelected: _type == ObligationType.oneTime,
              onTap: () => setState(() => _type = ObligationType.oneTime),
            ),
          ),
          Expanded(
            child: _TypeButton(
              title: 'EMI',
              isSelected: _type == ObligationType.emi,
              onTap: () => setState(() => _type = ObligationType.emi),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    Function(String) onChanged, {
    TextInputType? keyboardType, 
    int maxLines = 1, 
    IconData? icon, 
    String? initialValue,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? (initialValue ?? (label == 'Title' ? _title : (label == 'Category' ? _category : _notes))) : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (v) {
        if (label.contains('(Optional)') || label.contains('Interest') || label.contains('Balance') || label.contains('Duration')) return null;
        return v == null || v.isEmpty ? 'Required' : null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: _type == ObligationType.emi ? 'Monthly EMI Amount' : 'Amount',
        prefixIcon: const Icon(Icons.currency_rupee),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) => _amount = double.tryParse(v) ?? 0,
      validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null ? 'Enter valid amount' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _categories.contains(_category) ? _category : 'General',
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
      ),
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<PriorityLevel>(
      isExpanded: true,
      initialValue: _priority,
      decoration: InputDecoration(
        labelText: 'Priority',
        prefixIcon: const Icon(Icons.low_priority),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: PriorityLevel.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
      onChanged: (v) => setState(() => _priority = v!),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context, 
          initialDate: _startDate, 
          firstDate: DateTime(2000), 
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _startDate = date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _type == ObligationType.emi ? 'First EMI Date' : 'Due Date',
          prefixIcon: const Icon(Icons.date_range),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _submit,
        child: const Text('Add Obligation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSmartParserBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.15),
            const Color(0xFF06B6D4).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ 1-TAP ZERO-TYPING IMPORT',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      'Paste sanction letter, statement or SMS to auto-fill',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.document_scanner_rounded, size: 16),
              label: const Text('Auto-Detect from Statement / SMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.4)),
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: _showSmartParserModal,
            ),
          ),
        ],
      ),
    );
  }

  void _showSmartParserModal() {
    final textController = TextEditingController();
    ParsedStatementResult? parsed;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 20,
              right: 20,
              top: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Statement & SMS Parser',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Paste raw text from your loan sanction letter, bank credit card statement, or deduction SMS.',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.description_outlined, size: 14, color: AppTheme.primary),
                        label: const Text('Sample HDFC Sanction Letter', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        onPressed: () {
                          HapticService.selection();
                          textController.text =
                              'Sanction Letter: HDFC Bank Personal Loan. Sanctioned Amount: Rs. 5,00,000. Monthly EMI: Rs. 13,200. Interest Rate: 10.75% p.a. Tenure: 48 months. Due on: 5th of every month.';
                          final res = ref.read(statementParserServiceProvider).parseText(textController.text);
                          setModalState(() => parsed = res);
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.credit_card_outlined, size: 14, color: Color(0xFF38BDF8)),
                        label: const Text('Sample Credit Card Statement', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        onPressed: () {
                          HapticService.selection();
                          textController.text =
                              'ICICI Bank Credit Card Statement for Oct 2026. Total Amount Due: ₹ 45,800. Minimum Amount Due: ₹ 2,290. Payment Due Date: on 22nd.';
                          final res = ref.read(statementParserServiceProvider).parseText(textController.text);
                          setModalState(() => parsed = res);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Paste statement text or loan agreement here...',
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    onChanged: (text) {
                      final res = ref.read(statementParserServiceProvider).parseText(text);
                      setModalState(() => parsed = res);
                    },
                  ),
                  if (parsed != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DETECTED FINANCIAL ASSET',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${(parsed!.confidenceScore * 100).toInt()}% Match',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            parsed!.title,
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('BALANCE / TOTAL', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                                    Text('₹ ${parsed!.totalBalance.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('MONTHLY EMI', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                                    Text('₹ ${parsed!.monthlyAmount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primary)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('INTEREST', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                                    Text('${parsed!.interestRate}% p.a.', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Apply & Auto-Fill Form', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          HapticService.success();
                          final p = parsed!;
                          _title = p.title;
                          _titleController.text = p.title;
                          _amount = p.monthlyAmount;
                          _amountController.text = p.monthlyAmount.toStringAsFixed(0);
                          _totalBalance = p.totalBalance;
                          _totalBalanceController.text = p.totalBalance.toStringAsFixed(0);
                          _interestRate = p.interestRate;
                          _interestRateController.text = p.interestRate.toString();
                          if (p.emiDurationMonths != null) {
                            _emiDuration = p.emiDurationMonths;
                            _durationController.text = p.emiDurationMonths.toString();
                          }
                          _type = p.type;
                          _priority = p.priority;
                          _category = p.category;
                          if (p.dueDate != null) {
                            _startDate = p.dueDate!;
                          }
                          setState(() {});
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Form auto-filled from statement! ✨'),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() async {
    _title = _titleController.text.trim();
    _amount = double.tryParse(_amountController.text.trim()) ?? 0;
    _totalBalance = double.tryParse(_totalBalanceController.text.trim()) ?? 0;
    _interestRate = double.tryParse(_interestRateController.text.trim()) ?? 0;
    _emiDuration = int.tryParse(_durationController.text.trim());
    _notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (_formKey.currentState!.validate()) {
      if (widget.obligation == null) {
        final companion = ObligationsCompanion.insert(
          title: _title,
          type: _type,
          amount: _amount,
          startDate: _startDate,
          priority: _priority,
          category: _category,
          emiDurationMonths: drift.Value(_emiDuration),
          gracePeriodDays: drift.Value(_gracePeriodDays),
          totalBalance: drift.Value(_totalBalance),
          interestRate: drift.Value(_interestRate),
          notes: drift.Value(_notes),
          nextDueDate: drift.Value(_startDate),
        );
        await ref.read(obligationRepositoryProvider).createObligation(companion);
      } else {
        final updated = widget.obligation!.copyWith(
          title: _title,
          type: _type,
          amount: _amount,
          startDate: _startDate,
          priority: _priority,
          category: _category,
          emiDurationMonths: drift.Value(_emiDuration),
          gracePeriodDays: _gracePeriodDays,
          totalBalance: _totalBalance,
          interestRate: _interestRate,
          notes: drift.Value(_notes),
          updatedAt: DateTime.now(),
        );
        await ref.read(obligationRepositoryProvider).updateObligation(updated);
      }
      
      if (mounted) {
        if (_isAdLoaded && _interstitialAd != null) {
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              Navigator.pop(context);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              Navigator.pop(context);
            },
          );
          _interstitialAd!.show();
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  void _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Obligation'),
        content: const Text('Are you sure you want to delete this obligation? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.obligation != null) {
      await ref.read(obligationRepositoryProvider).deleteObligation(widget.obligation!.id);
      if (mounted) Navigator.pop(context);
    }
  }
  Widget _buildPaymentWindowSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Payment Window', 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _gracePeriodDays == 0 ? 'Exact Date' : '+ $_gracePeriodDays Days', 
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          value: _gracePeriodDays.toDouble(),
          min: 0,
          max: 15,
          divisions: 15,
          activeColor: AppTheme.primary,
          onChanged: (v) {
            HapticService.selection();
            setState(() => _gracePeriodDays = v.toInt());
          },
        ),
        Text('Due between the start date and $_gracePeriodDays days after.', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}


class _TypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title, 
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
class _StaggeredEntry extends StatelessWidget {
  final Widget child;
  final int delay;

  const _StaggeredEntry({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 400 + delay),
          curve: Curves.easeOutQuint,
          child: Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
