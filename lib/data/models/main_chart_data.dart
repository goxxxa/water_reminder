class MainChartData {
  String date;
  String totalWater;

  MainChartData({required this.date, required this.totalWater});

  @override
  String toString() {
    return '{date: $date, totalWater: $totalWater}';
  }
}
