class Calorie {
  double walk_speed = 79.8; // [m/minute]
  double walk_distance = 0.0;//[m] 

  double height=170; // 変数だけを宣言[cm]
  double weight=66;//[kg]
  int count_walk;
  
  late double length_walk; // コンストラクタで初期化される変数
  late double time_work;
  late double ex;
  late double Kcal;
  late double fat;
  // コンストラクタで値を設定し、計算を行う
  Calorie(this.count_walk) {
    // コンストラクタ内では、すべてのインスタンス変数にアクセスできる
    
    this.length_walk = this.height * 0.45;//歩幅
    walk_distance=count_walk*length_walk/100;   //歩幅*歩数[cm]/1000=[m]
    // static変数はクラス名を使ってアクセスする
    this.time_work = walk_distance / this.walk_speed/60;//[m]/[m/minute]/1000
    ex=3.0*time_work;
    Kcal=1.05*ex*weight; 
    fat=Kcal/7.2;
  }
}