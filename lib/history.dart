import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team/bar.dart';
import 'date.dart';
import 'main.dart';
import 'calo.dart';
import 'home.dart';

class HistoryState extends StatefulWidget {
  final DateManager dateManager;
  final barGroups;
  const HistoryState({super.key, required this.dateManager,required this.barGroups});

  @override
  State<HistoryState> createState() => HistoryPage();
}

class HistoryPage extends State<HistoryState> {
  Map<String, int> _historyData = {};
  bool _isLoading = true;
  late List<BarChartGroupData> barGroups;
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  late int _stepCount; 
  Future<void> _loadHistory() async {
    final Map<String, int> loadedData = {};
    final today = DateTime.now();
    barGroups= await widget.barGroups;
    _stepCount=await widget.dateManager.loadStep(widget.dateManager.getTodaydate());
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
    final sortedDates = _historyData.keys.toList()
      ..sort((a, b) => b.compareTo(a));
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

                //カロリー
                final calClass = Calorie(steps);
                final consumeCal = calClass.Kcal;
                final consumeFat = calClass.fat;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.directions_walk,
                      color: Colors.blue,
                    ),

                    title: Text(
                      _formatDisplayDate(dateString),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${consumeCal.toStringAsFixed(1)} Kcal  /  ${consumeFat.toStringAsFixed(1)} g',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Text(
                      '${formatter.format(steps)}歩',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 60,
              child: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
            ),

            const VerticalDivider(
              color: Colors.grey, // 線の色
              thickness: 1, // 線の太さ
              indent: 10, // 上の余白
              endIndent: 10, // 下の余白
            ),

            SizedBox(
              width: 100,
              height: 60,
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
            ),

            const VerticalDivider(
              color: Colors.grey, // 線の色
              thickness: 1, // 線の太さ
              indent: 10, // 上の余白
              endIndent: 10, // 下の余白
            ),

            SizedBox(
              width: 100,
              height: 60,
              child: IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute (
                      builder: (context) => barState (
                        stepCount: _stepCount,
                        dateManager: widget.dateManager,
                        barGroups: barGroups,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
