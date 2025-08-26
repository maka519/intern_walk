import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

// --- アプリケーションのエントリーポイント ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Pedometer',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const PedometerScreen(),
    );
  }
}
//歩行速度を1.33 m/s
// --- 歩数計のメイン画面 ---
class PedometerScreen extends StatefulWidget {
  const PedometerScreen({super.key});

  @override
  State<PedometerScreen> createState() => _PedometerScreenState();
}

class _PedometerScreenState extends State<PedometerScreen> {
  int _stepCount = 0;
  StreamSubscription? _accelerometerSubscription;
  
  // 歩数としてカウントするための揺れの大きさのしきい値
  // この値はデバイスや歩き方によって調整が必要です
  final double _stepThreshold = 11.5; 

  // 一度ピークを検出した後、次のステップを検出可能にするためのフラグ
  bool _isPeak = false;

  double walk_speed= 1.33;//平均の歩行の速さ　[m/s]
  double walk_distance= 0.0;//歩行距離のへんすう[km]

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    // 加速度センサーからのデータストリームを購読
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        // 3軸の加速度からベクトル（揺れの大きさ）を計算
        double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

        // 揺れの大きさがしきい値を超え、かつまだピーク状態でない場合
        if (magnitude > _stepThreshold && !_isPeak) {
          setState(() {
            _stepCount++;
          });
          _isPeak = true; // ピーク状態にする
        } 
        // 揺れの大きさがしきい値を下回り、かつピーク状態だった場合
        else if (magnitude < _stepThreshold && _isPeak) {
          _isPeak = false; // 次のステップを検出できるようにリセット
        }
      },
    );
  }

  // カウントをリセットする関数
  void _resetCount() {
    setState(() {
      _stepCount = 0;
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
        title: const Text('シンプルな歩数計'),
        backgroundColor: Colors.teal.shade100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '歩数:',
              style: TextStyle(fontSize: 32, color: Colors.grey),
            ),
            Text(
              '$_stepCount',
              style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetCount,
        tooltip: 'Reset',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}