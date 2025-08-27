import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DateManager{
  //今日の日付を取得
  String getTodaydate(){
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');//形式設定
    return formatter.format(now);
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

  bool DateChange(String lastSavedDate) {
    return lastSavedDate != getTodaydate();
  }
}