import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class DateManager {
  Future<void> saveTotalSteps(int totalSteps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_steps', totalSteps);
  }

  /// 総歩数を読み込みます。
  Future<int> loadTotalSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('total_steps') ?? 0;
  }

    /// すでに起動したことがあれば、falseを返します。
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    // 'first_launch_date' というキーでデータを探す
    final firstLaunchDate = prefs.getString('first_launch_date');
    //初めての起動
    if (firstLaunchDate == null) {
      final todayString = getTodaydate();
      // 今日を初回起動日として保存する
      await prefs.setString('first_launch_date', todayString);
      return true; // 初回起動なので true を返す
    }
    //初回起動ではない
    return false;
  }

  /// 保存されている初回起動日を読み込む
  Future<String?> loadFirstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('first_launch_date');
  }

  //今日の日付を取得
  String getTodaydate([DateTime? date]) {
    final dateToFormat = date ?? DateTime.now(); 
    final formatter = DateFormat('yyyy/MM/dd');
    return formatter.format(dateToFormat);
  }

  //歩数の保存
  Future<void> saveStep(String dateString, int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'steps_$dateString';
    await prefs.setInt(key, steps);
  }

  //指定された日付の歩数を読み込み
  Future<int> loadStep(String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'steps_$dateString';
    return prefs.getInt(key) ?? 0;
  }

   Future<void> saveStepList(String currentDate,List<BarChartGroupData> barGroups) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> dataToSave = barGroups.map((group) {
      return {
        'x': group.x,
        'barRods': group.barRods.map((rod) {
          return {
            'toY': rod.toY,
            'width': rod.width,
            'color': rod.color?.toARGB32(),
          };
        }).toList(),
      };
    }).toList();
    final String jsonString = jsonEncode(dataToSave);
    await prefs.setString(currentDate, jsonString);
  }
  //ローカルストレージからロード
Future<List<BarChartGroupData>> loadList(String currentDate,List<BarChartGroupData> barGroups)async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(currentDate);
   late final List<BarChartGroupData>newBarGroups =[]; 
    if (jsonString != null) {
      final List<dynamic> loadedData = jsonDecode(jsonString);
      newBarGroups.addAll(loadedData.map((data) {
        return BarChartGroupData(
          x: (data['x'] as num).toInt(), // numをdoubleに明示的にキャスト
          barRods: (data['barRods'] as List).map((rodData) {
            return BarChartRodData(
              toY: (rodData['toY'] as num).toDouble(), // numをdoubleに明示的にキャスト
              width: (rodData['width'] as num).toDouble(), // numをdoubleに明示的にキャスト
            );
          }).toList(),
        );
      }).toList());
    }
    return newBarGroups;
}
//棒グラフのストレージの破壊
 Future<void> rmList(String currentDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentDate);
 }

 Future<void> rmind(String currentDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('ind_${currentDate}');
 }

   Future<void> saveind(String dateString, int ind) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ind_$dateString';
    await prefs.setInt(key, ind);
  }

  //指定された日付の歩数を読み込み
  Future<int> loadind(String dateString) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ind_$dateString';
    return prefs.getInt(key) ?? 0;
  }

}
