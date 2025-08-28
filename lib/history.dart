import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'date.dart';
import 'main.dart';

class HistoryState extends StatefulWidget {
  final DateManager dateManager;
  const HistoryState({super.key, required this.dateManager});

  @override
  State<HistoryState> createState() => HistoryPage();
}

class HistoryPage extends State<HistoryState> {
  Map<String, int> _historyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final Map<String, int> loadedData = {};
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateString = widget.dateManager.getTodaydate(date);
      final steps = await widget.dateManager.loadStep(dateString);
      if (steps > 0) {
        loadedData[dateString] = steps;
      }
    }
    if (mounted) {
      setState(() {
        _historyData = loadedData;
        _isLoading = false;
      });
    }
  }

  String _formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('M月d日 (E)', 'ja_JP').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _historyData.keys.toList()..sort((a, b) => b.compareTo(a));
    return Scaffold(
      appBar: AppBar(
        title: const Text('歩数の履歴'),
        backgroundColor: Colors.blue.shade100,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : sortedDates.isEmpty
              ? const Center(child: Text('履歴データがありません'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final dateString = sortedDates[index];
                    final steps = _historyData[dateString]!;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.directions_walk, color: Colors.blue),
                        title: Text(_formatDisplayDate(dateString)),
                        trailing: Text('${formatter.format(steps)} 歩'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NextState(stepCount: steps,barGroups:[]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.menu), onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => NextState(stepCount: 0,barGroups: [],)));
            }),
            IconButton(icon: const Icon(Icons.home), onPressed: () => Navigator.pop(context)),
            IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}