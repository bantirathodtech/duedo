import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/app_enums.dart';
import '../../services/haptic_service.dart';
import '../theme/app_theme.dart';
import '../widgets/freedom_horizon_timeline.dart';
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Digital Visual Instrument: Freedom Horizon Timeline
                FreedomHorizonTimeline(
                  obligations: state.obligations,
                  currencyFormat: currencyFormat,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // 2. Interactive Calendar Matrix
                Container(
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
                const SizedBox(height: 20),

                // 3. Selected Day Schedule Section
                _buildEventList(_selectedDay ?? _focusedDay, viewModel, currencyFormat),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available_rounded, size: 56, color: AppTheme.primary.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              const Text('Clear Schedule', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(DateFormat('MMMM dd, yyyy').format(date), style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SCHEDULED FOR ${DateFormat('MMM dd').format(date).toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${events.length} DUE',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...events.map((obligation) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.glassDecoration(context),
          child: ListTile(
            contentPadding: const EdgeInsets.all(18),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.payment_rounded, color: AppTheme.primary, size: 24),
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
                    fontSize: 17, 
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
        )),
      ],
    );
  }
}
