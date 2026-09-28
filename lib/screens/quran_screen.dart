import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/day_amal_data.dart';
import '../services/storage_service.dart';
import 'zikr_screen.dart';

// Page 2: আজকের তিলাওয়াত
class QuranScreen extends StatefulWidget {
  final DateTime date;
  const QuranScreen({super.key, required this.date});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  DayAmalData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StorageService.loadDay(widget.date);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_data == null) return;
    await StorageService.saveDay(_data!);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ZikrScreen(date: widget.date)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আজকের তিলাওয়াত')),
      body: _loading || _data == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'আজকের তিলাওয়াতের অবস্থা',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          ...quranOptionLabels.entries.map((opt) {
                            return RadioListTile<int>(
                              title: Text(opt.value),
                              value: opt.key,
                              groupValue: _data!.quranStatus,
                              onChanged: (v) => setState(() => _data!.quranStatus = v),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Previous Page'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Submit & Go to Zikr Page'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
