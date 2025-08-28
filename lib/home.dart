import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'main.dart';
import 'history.dart';
import 'date.dart';
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:team/bar.dart';

//歩行速度を1.33 m/s
// --- 歩数計のメイン画面 ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _stepCount = 0;
  StreamSubscription? _accelerometerSubscription;

  final DateManager _dateManager = DateManager(); // DateManagerのインスタンスを作成
  String _currentDate = ''; // 現在カウントしている日付を保持

  // 歩数としてカウントするための揺れの大きさのしきい値
  final double _stepThreshold = 11.5;

  // 一度ピークを検出した後、次のステップを検出可能にするためのフラグ
  bool _isPeak = false;

  List<BarChartGroupData> barGroups = [
    BarChartGroupData(
      x: 1,
      barRods: [
        BarChartRodData(toY: 30.toDouble(), width: 15, color: Colors.green),
      ],
    ),
  ]; //日付と歩数
  late int bord;
  int ind = 1;

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  void _initializeHome() async {
    // 今日の日付を取得し、その日付の歩数を読み込む
    _currentDate = _dateManager.getTodaydate();
    final savedSteps = await _dateManager.loadStep(_currentDate);
    final savedList = await _dateManager.loadList(_currentDate, barGroups);
    final savedind = await _dateManager.loadind(_currentDate);
    if (mounted) {
      setState(() {
        _stepCount = savedSteps;
        barGroups = savedList;
        bord = _stepCount + 10;
        ind = savedind;
      });
    }
    _startListening(); // センサーの監視を開始
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) async {
      final todaydate = _dateManager.getTodaydate();
      // 日付が変わったかチェック
      if (todaydate != _currentDate) {
        // 日付が変わっていたら、前日(_currentDateString)の歩数(_stepCount)を保存
        await _dateManager.saveStep(_currentDate, _stepCount);
        barGroups.add(
          BarChartGroupData(
            x: ind,
            barRods: [
              BarChartRodData(
                toY: _stepCount.toDouble(),
                width: 15,
                color: Colors.green,
              ),
            ],
          ),
        );
        ind++;
        await _dateManager.saveStepList(_currentDate, barGroups);
        await _dateManager.saveStep(_currentDate, ind);

        // 新しい日のためにリセット
        if (mounted) {
          setState(() {
            _stepCount = 0; // 歩数カウントを0に
            _currentDate = todaydate; // 現在の日付を更新
          });
        }
      }

      // 3軸の加速度からベクトル（揺れの大きさ）を計算
      double magnitude = sqrt(
        pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2),
      );

      // 揺れの大きさがしきい値を超え、かつまだピーク状態でない場合
      if (magnitude > _stepThreshold && !_isPeak) {
        setState(() {
          _stepCount++;
        });
        await _dateManager.saveStep(_currentDate, _stepCount);
        _isPeak = true; // ピーク状態にする
      }
      // 揺れの大きさがしきい値を下回り、かつピーク状態だった場合
      else if (magnitude < _stepThreshold && _isPeak) {
        _isPeak = false; // 次のステップを検出できるようにリセット
      }
    });
  }

  @override
  void dispose() {
    // 画面が破棄されるときに、センサーの購読を必ずキャンセルする
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('万数計'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Stack(
        children: [
          //背景画像設定
          /*
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/bg_dote.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          */
          Center(
            child: Container(
              /*
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 5.0),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.9),
              ),
              */
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '日付: $_currentDate', // 今日の日付を表示
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                  const Text(
                    '今日の歩数:',
                    style: TextStyle(fontSize: 32, color: Colors.grey),
                  ),

                  Text(
                    '${formatter.format(_stepCount)}',
                    style: TextStyle(
                      fontSize: _stepCount > 1000000000 ? 100 : 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HistoryState(dateManager: _dateManager),
                  ),
                );
              },
            ),
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => barState(
                      stepCount: _stepCount,
                      dateManager: _dateManager,
                      barGroups: barGroups,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
