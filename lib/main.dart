import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calo.dart';
import 'date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'history.dart';

final formatter = NumberFormat("#,###");
// --- アプリケーションのエントリーポイント ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedometer',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
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
  int _stepCount = 10000;
  StreamSubscription? _accelerometerSubscription;

  final DateManager _dateManager = DateManager(); // DateManagerのインスタンスを作成
  String _currentDate = ''; // 現在カウントしている日付を保持

  // 歩数としてカウントするための揺れの大きさのしきい値
  final double _stepThreshold = 11.5;

  // 一度ピークを検出した後、次のステップを検出可能にするためのフラグ
  bool _isPeak = false;

  List<BarChartGroupData> barGroups = [];//日付と歩数  

  late int bord;
  int ind=1;
  //double walk_speed= 1.33;//平均の歩行の速さ　[m/s]
  //double walk_distance= 0.0;//歩行距離のへんすう[km]
  double walk_speed = 1.33; //平均の歩行の速さ　[m/s]
  double walk_distance = 0.0; //歩行距離のへんすう[km]

  @override
  void initState() {
    super.initState();
    _initializePedometer();
  }

  void _initializePedometer() async {
    // 今日の日付を取得し、その日付の歩数を読み込む
    _currentDate = _dateManager.getTodaydate();
    final savedSteps = await _dateManager.loadStep(_currentDate);
    final savedList = await _dateManager.loadList(_currentDate,barGroups);
    final savedind  = await _dateManager.loadind(_currentDate);
    if (mounted) {
      setState(() {
        _stepCount = savedSteps;
        barGroups=savedList;
        bord=_stepCount+10;
        ind =savedind;
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
        barGroups.add(
          BarChartGroupData(x: ind, barRods: [
          BarChartRodData(toY: _stepCount.toDouble(), width: 15, color: Colors.green),
  ]),
);
        ind++;
       //graphで追加
        // 日付が変わっていたら、前日(_currentDateString)の歩数(_stepCount)を保存
        await _dateManager.saveStep(_currentDate, _stepCount);

        await _dateManager.saveStepList(_currentDate,barGroups);
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
         flexibleSpace: Container(
              decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage("https://gingerweb.jp/wp-content/uploads/2020/12/rectangle_large_type_2_7398bd1f4810549fd5a48efceb3067f5.jpg",),
                  fit: BoxFit.cover),
            )
        ),
        title: const Text('万数計'),
        backgroundColor: Colors.teal.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NextState(
                  stepCount:_stepCount,
                  barGroups :barGroups,
                )),
              );
            },
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
                    builder: (context) => HistoryState(dateManager: _dateManager),
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
                    builder: (context) => NextState(stepCount: _stepCount),
                  ),
                );
              },
            ),
          ],
        ),
      ),
   floatingActionButton: FloatingActionButton(
      onPressed: ()async{
       await _dateManager.rmList(_currentDate);//棒グラフ破壊
       await _dateManager.rmind(_currentDate);//ind破壊
//         barGroups.add(
//          BarChartGroupData(x: ind, barRods: [
//          BarChartRodData(toY: _stepCount.toDouble(), width: 15, color: Colors.green),
//          ]),
//            );
//        ind++;
//        await _dateManager.saveStepList(_currentDate,barGroups);
//         await _dateManager.saveStep(_currentDate, ind);
    },
    ),
    );
  }
}

double distance = 0.0;

class NextState extends StatefulWidget {
  final int stepCount;
  final List<BarChartGroupData> barGroups;
  const NextState({
    super.key,
    required this.stepCount,
    required this.barGroups
    });
  const NextState({super.key, required this.stepCount});

  @override
  State<NextState> createState() => NextPage();
}

class NextPage extends State<NextState> {
  final TextEditingController textController = TextEditingController();
  late int _localStepCount;
  late double consume_cal;
  late double consumeFat;
  late List<BarChartGroupData> _barGroups;
void calo(){
      setState((){
        final calClass=Calorie(_localStepCount);
        consume_cal=calClass.Kcal;
        consumeFat=calClass.fat;
      }
      );
    }
    @override
    initState(){
      super.initState();
      _localStepCount=widget.stepCount;
      _barGroups=widget.barGroups;
      calo(); 
      
    }
  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(appBar: AppBar(title: const Text('次のページ')),
    body: Center(
      child :Column(
        children :[
          Text(
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
    calo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('次のページ'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          '消費カロリー${consume_cal.toStringAsFixed(2)}Kcal\n脂肪燃焼量${consumeFat.toStringAsFixed(2)}g',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          ],
        ),
                const SizedBox(height: 32), // スペーサー
        SingleChildScrollView( // グラフ全体を横スクロールさせる
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  // グラフの幅を動的に計算
                  width: 300+_barGroups.length * 50.0, // 各棒の幅(15) + グループ間のスペース(10) + 余白
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
        ]
      ),
        
      ),
      
    );
  }
} 
