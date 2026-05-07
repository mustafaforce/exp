import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../providers/reports_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _preset = 'month';

  final _presets = {
    'week': 'Week',
    'month': 'Month',
    'lastMonth': 'Last Mo.',
    'year': 'Year',
    'custom': 'Custom',
  };

  @override
  void initState() {
    super.initState();
    _setPreset('month');
  }

  void _setPreset(String preset) {
    final now = DateTime.now();
    setState(() {
      _preset = preset;
      switch (preset) {
        case 'week':
          final range = DateUtilsX.getCurrentWeekRange();
          _startDate = range[0];
          _endDate = range[1];
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'lastMonth':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          break;
        case 'custom':
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateRange = {
      'start': DateUtilsX.toDb(_startDate),
      'end': DateUtilsX.toDb(_endDate),
    };
    final reportAsync = ref.watch(reportsProvider(dateRange));

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          // Preset chips
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
            child: Row(
              children: _presets.entries.map((entry) {
                final isSelected = _preset == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ChoiceChip(
                    label: Text(entry.value, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) {
                      if (entry.key == 'custom') {
                        _pickDateRange();
                      } else {
                        _setPreset(entry.key);
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${DateUtilsX.display(_startDate)} — ${DateUtilsX.display(_endDate)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          Divider(height: 8, color: theme.colorScheme.outline.withValues(alpha: 0.2)),

          // Report content
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) {
                if (data == null) {
                  return Center(child: Text('No data',
                      style: theme.textTheme.bodySmall));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 20),
                  child: Column(
                    children: [
                      // Summary row
                      Row(
                        children: [
                          Expanded(child: _MiniCard(
                            label: 'Income',
                            amount: data.totalIncome,
                            color: const Color(0xFF10B981),
                          )),
                          const SizedBox(width: 6),
                          Expanded(child: _MiniCard(
                            label: 'Expenses',
                            amount: data.totalExpenses,
                            color: theme.colorScheme.error,
                          )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(child: _MiniCard(
                            label: 'Net',
                            amount: data.net,
                            color: data.net >= 0
                                ? const Color(0xFF10B981)
                                : theme.colorScheme.error,
                          )),
                          const SizedBox(width: 6),
                          Expanded(child: _MiniCard(
                            label: 'Daily Avg',
                            amount: data.dailyAverage,
                            color: theme.colorScheme.primary,
                          )),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Export
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () => _exportCsv(data),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category breakdown
                      if (data.categoryRows.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('By Category', style: theme.textTheme.titleLarge),
                        ),
                        const SizedBox(height: 6),
                        ...data.categoryRows.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(cat.category,
                                      style: theme.textTheme.bodySmall),
                                ),
                                Text(
                                  CurrencyFormatter.format(cat.amount),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '${cat.percentage.toStringAsFixed(0)}%',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final start = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (start == null || !mounted) return;

    final end = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (end == null || !mounted) return;

    setState(() {
      _startDate = start;
      _endDate = end;
      _preset = 'custom';
    });
  }

  Future<void> _exportCsv(ReportData data) async {
    try {
      final path = await exportToCsv(data);
      await shareFile(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _MiniCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
            const SizedBox(height: 2),
            Text(
              CurrencyFormatter.format(amount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
