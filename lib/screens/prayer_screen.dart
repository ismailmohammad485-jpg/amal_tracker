import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/day_amal_data.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';
import 'quran_screen.dart';

// Page 1: আজকের দিনের নামাজ আদায়
class PrayerScreen extends StatefulWidget {
  final DateTime date;
  const PrayerScreen({super.key, required this.date});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late DateTime _selectedDate;
  DayAmalData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await StorageService.loadDay(_selectedDate);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _load();
    }
  }

  Future<void> _submit() async {
    if (_data == null) return;
    await StorageService.saveDay(_data!);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranScreen(date: _selectedDate)),
    );
  }

  Widget _buildPrayerCard(String key) {
    final label = prayerLabels[key]!;
    final current = _data!.prayers[key];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ...prayerOptionLabels.entries.map((opt) {
              return RadioListTile<int>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(opt.value),
                value: opt.key,
                groupValue: current,
                onChanged: (v) {
                  setState(() => _data!.prayers[key] = v);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd MMMM yyyy', 'bn').format(_selectedDate);
    return Scaffold(
      appBar: AppBar(
        title: const Text('আজকের দিনের নামাজ আদায়'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'তারিখ নির্বাচন করুন',
            onPressed: _pickDate,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading || _data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.event),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'তারিখ: $dateLabel',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...prayerKeys.map(_buildPrayerCard),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit & Go to Quran Page'),
                  ),
                ),
              ],
            ),
    );
  }
}
