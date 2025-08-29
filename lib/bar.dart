import 'package:flutter/material.dart';
import 'calo.dart';
import 'package:fl_chart/fl_chart.dart';
import 'history.dart';
import 'date.dart';
import 'home.dart';

double distance = 0.0;

class barState extends StatefulWidget {
  final int stepCount;
  final List<BarChartGroupData> barGroups;
  final DateManager dateManager;

  const barState({
    super.key,
    required this.stepCount,
    required this.barGroups,
    required this.dateManager,
  });

  @override
  State<barState> createState() => barPage();
}

class barPage extends State<barState> {
  final TextEditingController textController = TextEditingController();
  late int _localStepCount;
  late double consume_cal;
  late double consumeFat;
  late List<BarChartGroupData> _barGroups;
  void calo() {
    setState(() {
      final calClass = Calorie(_localStepCount);
      consume_cal = calClass.Kcal;
      consumeFat = calClass.fat;
    });
  }

  @override
  initState() {
    super.initState();
    _localStepCount = widget.stepCount;
    _barGroups = widget.barGroups;
    calo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歩数グラフ'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              '消費カロリー${consume_cal.toStringAsFixed(2)}Kcal\n脂肪燃焼量${consumeFat.toStringAsFixed(2)}g',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32), // スペーサー
            SingleChildScrollView(
              // グラフ全体を横スクロールさせる
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                // グラフの幅を動的に計算
                width:
                    300 +
                    _barGroups.length * 50.0, // 各棒の幅(15) + グループ間のスペース(10) + 余白
                height: 500, // チャートに固定の高さを与える
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(
                      border: const Border(
                        top: BorderSide.none,
                        right: BorderSide.none,
                        left: BorderSide(width: 1),
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                    groupsSpace: 10,
                    barGroups: _barGroups, // すべてのデータをまとめて渡す
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(
              width: 100,
              height: 60,
              child: IconButton(
                icon: const Icon(Icons.menu),
                // IconButtonのonPressed()内のコードを以下のように修正
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HistoryState(dateManager: widget.dateManager,barGroups: _barGroups,),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            // 右から左へスライドするアニメーションを定義
                            const begin = Offset(-1.0, 0.0); // 開始位置（右）
                            const end = Offset.zero; // 終了位置（中央）
                            const curve = Curves.ease; // アニメーションのカーブ

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
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
                icon: const Icon(Icons.home),
                // IconButtonのonPressed()内のコードを以下のように修正
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomeScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            // 右から左へスライドするアニメーションを定義
                            const begin = Offset(-1.0, 0.0); // 開始位置（右）
                            const end = Offset.zero; // 終了位置（中央）
                            const curve = Curves.ease; // アニメーションのカーブ

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
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
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
