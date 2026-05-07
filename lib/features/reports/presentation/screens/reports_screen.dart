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
    final dateRange = (DateUtilsX.toDb(_startDate), DateUtilsX.toDb(_endDate));
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

                final netPrefix = data.net >= 0 ? '+' : '-';

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
                            amount: data.net.abs(),
                            color: data.net >= 0
                                ? const Color(0xFF10B981)
                                : theme.colorScheme.error,
                            prefix: netPrefix,
                          )),
                          const SizedBox(width: 6),
                          Expanded(child: _MiniCard(
                            label: 'Daily Avg',
                            amount: data.dailyAverage,
                            color: theme.colorScheme.primary,
                          )),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Transaction count
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 14,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '${data.transactions.length} transaction${data.transactions.length == 1 ? '' : 's'}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

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
                          final pct = cat.percentage / 100;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Row(
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
                                      width: 36,
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
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: pct.clamp(0, 1).toDouble(),
                                    minHeight: 4,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation(
                                      theme.colorScheme.primary,
                                    ),
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
  final String? prefix;

  const _MiniCard({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = prefix != null
        ? '$prefix${CurrencyFormatter.format(amount)}'
        : CurrencyFormatter.format(amount);
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
              formatted,
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
