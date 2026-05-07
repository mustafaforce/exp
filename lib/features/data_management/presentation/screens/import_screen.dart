import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../providers/data_management_provider.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  List<List<dynamic>>? _rows;
  String? _filePath;
  bool _isImporting = false;
  ImportResult? _result;

  // Column mapping state
  int _dateCol = 0;
  int _amountCol = 0;
  int? _categoryCol;
  int? _noteCol;
  int? _typeCol;
  bool _hasHeader = true;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final importer = ref.read(importProvider);
      try {
        final rows = await importer.parseFile(path);
        setState(() {
          _rows = rows;
          _filePath = path;
          _result = null;
          if (rows.isNotEmpty && rows[0].length >= 2) {
            _dateCol = 0;
            _amountCol = 1;
            _categoryCol = rows[0].length > 2 ? 2 : null;
            _noteCol = rows[0].length > 3 ? 3 : null;
            _typeCol = null;
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing file: $e')),
          );
        }
      }
    }
  }

  Future<void> _import() async {
    if (_rows == null) return;

    setState(() => _isImporting = true);

    final importer = ref.read(importProvider);
    final result = await importer.import(
      rows: _rows!,
      dateCol: _dateCol,
      amountCol: _amountCol,
      categoryCol: _categoryCol,
      noteCol: _noteCol,
      typeCol: _typeCol,
      hasHeader: _hasHeader,
    );

    setState(() {
      _isImporting = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Import CSV')),
      body: _rows == null
          ? EmptyState(
              icon: Icons.file_upload_outlined,
              headline: 'Import Transactions',
              description:
                  'Select a CSV file to import transactions.',
              ctaLabel: 'Select CSV File',
              onCta: _pickFile,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File info
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _filePath?.split('/').last ?? '',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickFile,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_rows!.length - (_hasHeader ? 1 : 0)} rows detected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Divider(),

                  // Header toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('First row is header'),
                    value: _hasHeader,
                    onChanged: (v) =>
                        setState(() => _hasHeader = v),
                  ),
                  const SizedBox(height: 8),

                  // Column mapping
                  Text('Column Mapping',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),

                  _ColumnSelector(
                    label: 'Date Column',
                    value: _dateCol,
                    columns: _rows!.isNotEmpty
                        ? _rows![0].length
                        : 0,
                    header: _hasHeader && _rows!.isNotEmpty
                        ? _rows![0][_dateCol].toString()
                        : null,
                    onChanged: (v) =>
                        setState(() => _dateCol = v),
                  ),
                  const SizedBox(height: 8),
                  _ColumnSelector(
                    label: 'Amount Column',
                    value: _amountCol,
                    columns: _rows!.isNotEmpty
                        ? _rows![0].length
                        : 0,
                    header: _hasHeader && _rows!.isNotEmpty
                        ? _rows![0][_amountCol].toString()
                        : null,
                    onChanged: (v) =>
                        setState(() => _amountCol = v),
                  ),
                  const SizedBox(height: 8),
                  _ColumnSelector(
                    label: 'Category Column',
                    value: _categoryCol ?? 0,
                    columns: _rows!.isNotEmpty
                        ? _rows![0].length
                        : 0,
                    header: _categoryCol != null &&
                            _hasHeader &&
                            _rows!.isNotEmpty
                        ? _rows![0][_categoryCol!].toString()
                        : null,
                    onChanged: (v) =>
                        setState(() => _categoryCol = v),
                    optional: true,
                    onClear: () =>
                        setState(() => _categoryCol = null),
                  ),
                  const SizedBox(height: 8),
                  _ColumnSelector(
                    label: 'Note Column',
                    value: _noteCol ?? 0,
                    columns: _rows!.isNotEmpty
                        ? _rows![0].length
                        : 0,
                    header: _noteCol != null &&
                            _hasHeader &&
                            _rows!.isNotEmpty
                        ? _rows![0][_noteCol!].toString()
                        : null,
                    onChanged: (v) =>
                        setState(() => _noteCol = v),
                    optional: true,
                    onClear: () =>
                        setState(() => _noteCol = null),
                  ),

                  const SizedBox(height: 16),

                  // Preview
                  Text('Preview (first 3 rows)',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: List.generate(
                          _rows![0].length,
                          (i) => DataColumn(
                              label: Text(
                                  'Col $i',
                                  style: theme
                                      .textTheme.labelSmall)),
                        ),
                        rows: _rows!
                            .skip(_hasHeader ? 1 : 0)
                            .take(3)
                            .map((row) => DataRow(
                                  cells: row
                                      .map((cell) => DataCell(Text(
                                          cell.toString(),
                                          style: theme
                                              .textTheme
                                              .bodySmall)))
                                      .toList(),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Import button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isImporting ? null : _import,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.file_upload),
                      label: Text(_isImporting
                          ? 'Importing...'
                          : 'Import'),
                    ),
                  ),

                  // Result
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: _result!.imported > 0
                          ? const Color(0xFF10B981)
                              .withValues(alpha: 0.1)
                          : theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Imported ${_result!.imported} transactions',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            if (_result!.skipped > 0)
                              Text(
                                '${_result!.skipped} skipped',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      theme.colorScheme.error,
                                ),
                              ),
                            if (_result!.errors.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8),
                                child: Text(
                                  _result!.errors
                                      .take(5)
                                      .join('\n'),
                                  style: theme.textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: theme
                                        .colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _ColumnSelector extends StatelessWidget {
  final String label;
  final int value;
  final int columns;
  final String? header;
  final ValueChanged<int> onChanged;
  final bool optional;
  final VoidCallback? onClear;

  const _ColumnSelector({
    required this.label,
    required this.value,
    required this.columns,
    this.header,
    required this.onChanged,
    this.optional = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: value,
            isDense: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: List.generate(
              columns,
              (i) => DropdownMenuItem(
                value: i,
                child: Text(
                  header != null ? '$header (Col $i)' : 'Column $i',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
        if (optional && onClear != null)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onClear,
          ),
      ],
    );
  }
}
