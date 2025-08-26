class Calorie {
  double walk_speed = 1.33; // [m/s]
  static double walk_distance = 0.0; // [km]

  double height=170; // 変数だけを宣言
  double weight=66;
  double count_walk;
  
  late double length_walk; // コンストラクタで初期化される変数
  late double time_work;

  // コンストラクタで値を設定し、計算を行う
  Calorie(this.count_walk) {
    // コンストラクタ内では、すべてのインスタンス変数にアクセスできる
    this.length_walk = this.height * 0.45;
    
    // static変数はクラス名を使ってアクセスする
    this.time_work = Calorie.walk_distance / this.walk_speed;
  }
}