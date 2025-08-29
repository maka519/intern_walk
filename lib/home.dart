import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'main.dart';
import 'history.dart';
import 'date.dart';
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:team/bar.dart';
import 'package:just_audio/just_audio.dart';

//歩行速度を1.33 m/s
// --- 歩数計のメイン画面 ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _stepCount = 0;
  int _totalStepCount = 0;
  StreamSubscription? _accelerometerSubscription;

  final DateManager _dateManager = DateManager(); // DateManagerのインスタンスを作成
  String _currentDate = ''; // 現在カウントしている日付を保持

  // 歩数としてカウントするための揺れの大きさのしきい値
  final double _stepThreshold = 11.5;

  // 一度ピークを検出した後、次のステップを検出可能にするためのフラグ
  bool _isPeak = false;

  List<BarChartGroupData> _barGroups = [
    BarChartGroupData(
      x: 1,
      barRods: [
        BarChartRodData(toY: 30.toDouble(), width: 15, color: Colors.green),
      ],
    ),
  ]; //日付_と歩数
  late int bord;
  int ind = 1;

  late AudioPlayer _audioPlayer; // AudioPlayerのインスタンス
  String _message = 'さあ、歩き出そう！'; // 表示するメッセージ
  int _lastPlayedGoal = 0; // 最後に効果音を鳴らした目標歩数

  // 目標とメッセージのマップ
  final Map<int, String> _goalMessages = {
    100: 'まずは100歩達成！良いスタート！',
    1000: '1,000歩達成！順調です！',
    3000: '3,000歩！素晴らしい！もう少し頑張ろう！',
    5000: '5,000歩達成！もう半分以上歩いたね！',
    8000: '8,000歩！目標まであと少し！',
    10000: '🎉 10,000歩達成！おめでとうございます！ 🎉',
  };

  @override
  void initState() {
    super.initState();
    _initializeHome();
    _audioPlayer = AudioPlayer();
    _loadStepSound(); // 歩数ごとの効果音を事前に読み込み
  }

    Future<void> _loadStepSound() async {
    try {
      await _audioPlayer.setAsset('assets/audios/レベルアップ・経験値アップ.mp3'); // 適切なパスに修正
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  // ▼▼▼【追加】目標達成時の効果音を鳴らす関数
  Future<void> _playGoalSound() async {
    try {
      // 目標達成時の別の効果音を設定する場合（例: goal_achieved.mp3）
      // await _audioPlayer.setAsset('assets/audios/goal_achieved.mp3');
      // await _audioPlayer.play();
      await _audioPlayer.seek(Duration.zero); // 最初から再生
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing goal sound: $e");
    }
  }

  void _initializeHome() async {
    await _dateManager.isFirstLaunch(); // 初回起動かチェック
    // 今日の日付を取得し、その日付の歩数を読み込む
    _currentDate = _dateManager.getTodaydate();
    final savedSteps = await _dateManager.loadStep(_currentDate);
    final totalSteps = await _dateManager.loadTotalSteps();
    final savedList = await _dateManager.loadList(_currentDate);
    final savedind = await _dateManager.loadind(_currentDate);
    int indexBar=savedList.length;
    indexBar-=30;
     if(indexBar<0){
          indexBar=0;
          debugPrint("savedListの長さ${savedList.length.toString()}");
          for(int i=indexBar;i<(savedList.length);i++){
            debugPrint("for文中の${savedList.length.toString()}");
            _barGroups.add(savedList[i]);
          }
            debugPrint("pp");
        }
        else{
          for(int i=indexBar;i<indexBar+30;i++){
          debugPrint(i.toString());
          _barGroups.add(savedList[i]);
        }
        }
     if (mounted) {
      setState(() {
        _stepCount = savedSteps;
        _totalStepCount = totalSteps; // 読み込んだ値をセット
        ind=savedind;
        _updateMessage(_stepCount);
      });
    }
    _startListening(); // センサーの監視を開始
  }

    //メッセージを更新する関数
  void _updateMessage(int currentSteps) {
    String newMessage = 'さあ、歩き出そう！';
    _goalMessages.forEach((goal, msg) {
      if (currentSteps >= goal) {
        newMessage = msg;
      }
    });
    // 特定の目標を達成した瞬間に効果音を鳴らす
    if (currentSteps > 0) { // 0歩で鳴らさないように
      // 100歩ごとの達成音を例として追加
      if (currentSteps % 100 == 0 && currentSteps != _lastPlayedGoal) {
        _playGoalSound();
        _lastPlayedGoal = currentSteps;
      }
    }
    _message = newMessage;
  }


  Future<int> _calculateTotalSteps() async {
    int total = 0;
    final firstLaunchDateString = await _dateManager.loadFirstLaunchDate();
    if (firstLaunchDateString != null) {
      // 日付の形式を 'yyyy/MM/dd' から 'yyyy-MM-dd' に変換してパース
      final firstLaunchDate = DateTime.parse(firstLaunchDateString.replaceAll('/', '-'));
      final today = DateTime.now();
      final difference = today.difference(firstLaunchDate).inDays;

      for (int i = 0; i <= difference; i++) {
        final date = today.subtract(Duration(days: i));
        final dateString = _dateManager.getTodaydate(date);
        total += await _dateManager.loadStep(dateString);
      }
    }
    return total;
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) async {
      final todaydate = _dateManager.getTodaydate();
      if (todaydate != _currentDate) {
        await _dateManager.saveStep(_currentDate, _stepCount);
        _barGroups.add(
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
        await _dateManager.saveStepList(_currentDate, _barGroups);
        await _dateManager.saveind(_currentDate,ind);
        await _dateManager.saveStep(_currentDate, _stepCount);
        if (mounted) {
          setState(() {
            _stepCount = 0;
            _currentDate = todaydate;
          });
        }
      }

      double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

      if (magnitude > _stepThreshold && !_isPeak) {
        // ▼▼▼【ここからロジックを修正】▼▼▼
        _stepCount++;
        _totalStepCount++;
        
        // UIを更新
        if (mounted) {
          setState(() {_updateMessage(_stepCount);});
        }
        
        // 今日の歩数と、更新された総歩数の両方を保存
        await _dateManager.saveStep(_currentDate, _stepCount);
        await _dateManager.saveTotalSteps(_totalStepCount);
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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateDataAfterNavigation() async {
    final totalSteps = await _calculateTotalSteps();
    if(mounted){
      setState(() {
        _totalStepCount = totalSteps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('万歩計'),
        automaticallyImplyLeading: false,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  '総歩数: ',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                Text(
                  formatter.format(_totalStepCount),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40), // 間隔を調整
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
                  const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Colors.orange,
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
                          HistoryState(dateManager: _dateManager,barGroups:_barGroups),
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
              child: IconButton(icon: const Icon(Icons.home), onPressed: () {}),
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
                    MaterialPageRoute(
                      builder: (context) => barState(
                        stepCount: _stepCount,
                        dateManager: _dateManager,
                        barGroups: _barGroups,
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
