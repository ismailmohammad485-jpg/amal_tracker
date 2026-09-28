import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/day_amal_data.dart';
import '../services/storage_service.dart';
import 'report_screen.dart';

// Page 3: আজকের জিকির
class ZikrScreen extends StatefulWidget {
  final DateTime date;
  const ZikrScreen({super.key, required this.date});

  @override
  State<ZikrScreen> createState() => _ZikrScreenState();
}

class _ZikrScreenState extends State<ZikrScreen> {
  DayAmalData? _data;
  bool _loading = true;
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _countControllers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _countControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final data = await StorageService.loadDay(widget.date);
    _nameControllers.clear();
    _countControllers.clear();
    for (final z in data.zikrList) {
      _nameControllers.add(TextEditingController(text: z.name));
      _countControllers.add(TextEditingController(text: z.count.toString()));
    }
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  void _addZikrRow() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _countControllers.add(TextEditingController(text: '0'));
    });
  }

  void _removeZikrRow(int index) {
    setState(() {
      _nameControllers.removeAt(index).dispose();
      _countControllers.removeAt(index).dispose();
    });
  }

  void _syncZikrList() {
    final list = <ZikrItem>[];
    for (int i = 0; i < _nameControllers.length; i++) {
      final name = _nameControllers[i].text.trim();
      final count = int.tryParse(_countControllers[i].text.trim()) ?? 0;
      if (name.isNotEmpty) {
        list.add(ZikrItem(name: name, count: count));
      }
    }
    _data!.zikrList = list;
  }

  Future<void> _submit() async {
    if (_data == null) return;
    _syncZikrList();
    await StorageService.saveDay(_data!);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportScreen(initialDate: widget.date)),
    );
  }

  Widget _toggleCard(String title, int? value, void Function(int?) onChanged) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ...zikrOptionLabels.entries.map((opt) {
              return RadioListTile<int>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(opt.value),
                value: opt.key,
                groupValue: value,
                onChanged: onChanged,
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আজকের জিকির')),
      body: _loading || _data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _toggleCard(
                  'সকালের আজকার',
                  _data!.sokalZikr,
                  (v) => setState(() => _data!.sokalZikr = v),
                ),
                _toggleCard(
                  'সন্ধ্যার আজকার',
                  _data!.sondhyaZikr,
                  (v) => setState(() => _data!.sondhyaZikr = v),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'আজকের জিকির',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              tooltip: 'জিকির যোগ করুন',
                              onPressed: _addZikrRow,
                            ),
                          ],
                        ),
                        for (int i = 0; i < _nameControllers.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _nameControllers[i],
                                    decoration: const InputDecoration(
                                      labelText: 'জিকিরের নাম',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _countControllers[i],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'সংখ্যা',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeZikrRow(i),
                                ),
                              ],
                            ),
                          ),
                        if (_nameControllers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'উপরের + বাটনে চাপ দিয়ে জিকির যোগ করুন',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        child: const Text('Submit & View Report'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
