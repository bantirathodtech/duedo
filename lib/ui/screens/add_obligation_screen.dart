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

class AddObligationScreen extends ConsumerStatefulWidget {
  final Obligation? obligation;
  const AddObligationScreen({super.key, this.obligation});

  @override
  ConsumerState<AddObligationScreen> createState() => _AddObligationScreenState();
}

class _AddObligationScreenState extends ConsumerState<AddObligationScreen> {
  final _formKey = GlobalKey<FormState>();
  
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
    // If date is far future or same as created but intended as no-date
    // For now, we'll just track the toggle state. 
    // If it's a one-time with no specific deadline, users can toggle this.
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
                    _StaggeredEntry(
                      delay: 0,
                      child: _buildSectionCard(
                        title: 'Basic Info',
                        child: Column(
                          children: [
                            _buildTypeSelector(),
                            const SizedBox(height: 24),
                            _buildTextField('Title', (v) => _title = v, icon: Icons.title_rounded),
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
                                    initialValue: _totalBalance.toString(),
                                    icon: Icons.account_balance_wallet_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    'Interest Rate (%)', 
                                    (v) => _interestRate = double.tryParse(v) ?? 0, 
                                    keyboardType: TextInputType.number,
                                    initialValue: _interestRate.toString(),
                                    icon: Icons.percent_rounded,
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
              color: AppTheme.primary.withOpacity(0.8),
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
        color: Theme.of(context).cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: const Text('No Specific Due Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: const Text('Marks as a high-priority "Must Pay" item', style: TextStyle(fontSize: 11)),
        value: _noDueDate,
        activeColor: AppTheme.primary,
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
            color: AppTheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildSummaryItem('Total Paid', '₹${totalPaid.toInt()}', AppTheme.primary),
                   _buildSummaryItem('Remaining', '₹${remaining.toInt()}', AppTheme.danger),
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
                CircleAvatar(radius: 4, backgroundColor: AppTheme.primary.withOpacity(0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '₹${p.amountPaid.toInt()} on ${DateFormat('MMM dd').format(p.paidDate)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (p.note != null) Text(p.note!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          )).toList(),
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
                if (mounted) Navigator.pop(context);
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
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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

  Widget _buildTextField(String label, Function(String) onChanged, {TextInputType? keyboardType, int maxLines = 1, IconData? icon, String? initialValue}) {
    return TextFormField(
      initialValue: initialValue ?? (label == 'Title' ? _title : (label == 'Category' ? _category : _notes)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.5),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Amount',
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
      value: _categories.contains(_category) ? _category : 'General',
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.5),
      ),
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<PriorityLevel>(
      value: _priority,
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

  void _submit() async {
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
          totalBalance: _totalBalance,
          interestRate: _interestRate,
          notes: drift.Value(_notes),
          updatedAt: DateTime.now(),
        );
        await ref.read(obligationRepositoryProvider).updateObligation(updated);
      }
      
      if (mounted) Navigator.pop(context);
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
            const Text('Payment Window', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(_gracePeriodDays == 0 ? 'Exact Date' : '+ $_gracePeriodDays Days', 
                 style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900)),
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
        Text('Due between the start date and ${_gracePeriodDays} days after.', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
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
        child: Text(
          title, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
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
