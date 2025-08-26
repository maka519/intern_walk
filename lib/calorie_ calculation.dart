class Calorie {
  double walk_speed = 1.33*60; // [m/minute]
  late double walk_distance = 0.0; 

  double height=170; // 変数だけを宣言
  double weight=66;
  double count_walk;
  
  late double length_walk; // コンストラクタで初期化される変数
  late double time_work;
  late double ex;
  late double Kcal;
  // コンストラクタで値を設定し、計算を行う
  Calorie(this.count_walk,this.walk_distance) {
    // コンストラクタ内では、すべてのインスタンス変数にアクセスできる
    
    this.length_walk = this.height * 0.45;
    walk_distance=count_walk*length_walk/1000;   
    // static変数はクラス名を使ってアクセスする
    this.time_work = walk_distance / this.walk_speed;
    ex=3.0*time_work;
    Kcal=1.05*ex*weight; 
  }
  double getCalculatedKcal() {
    return this.Kcal;
  }
}