import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/app_enums.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final state = ref.watch(homeViewModelProvider);
    final currencyFormat = NumberFormat.simpleCurrency(
      name: state.settings?.currency ?? '₹',
      decimalDigits: 0,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Payment Timeline',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          AppTheme.glassBackground(context),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassDecoration(context, opacity: 0.08, blur: 20),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      HapticService.selection();
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: (day) => viewModel.getObligationsForDay(day),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15), 
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                      ),
                      selectedDecoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4), 
                            blurRadius: 15, 
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      markerDecoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle),
                      defaultTextStyle: GoogleFonts.inter(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendTextStyle: GoogleFonts.inter(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      outsideTextStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900, 
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primary),
                      rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildEventList(_selectedDay!, viewModel, currencyFormat),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(DateTime date, HomeViewModel viewModel, NumberFormat format) {
    final events = viewModel.getObligationsForDay(date);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded, size: 64, color: AppTheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('Clear Schedule', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(DateFormat('MMMM dd, yyyy').format(date), style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final obligation = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: AppTheme.glassDecoration(context),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.payment_rounded, color: AppTheme.primary, size: 28),
            ),
            title: Text(
              obligation.title, 
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            subtitle: Text(
              obligation.category.toUpperCase(), 
              style: GoogleFonts.inter(
                color: Colors.grey.shade500, 
                fontSize: 10, 
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  format.format(obligation.amount),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900, 
                    fontSize: 18, 
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  obligation.type == ObligationType.emi ? 'MONTHLY' : 'ONE-TIME',
                  style: GoogleFonts.inter(
                    fontSize: 9, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
