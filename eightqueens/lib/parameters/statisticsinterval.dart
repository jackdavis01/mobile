enum StatisticsInterval {
  weekly('Weekly', 2),
  monthly('Monthly', 3),
  quarterly('Quarterly', 4),
  yearly('Yearly', 5),
  threeYearly('3-yearly', 6);

  const StatisticsInterval(this.label, this.apiValue);

  final String label;
  final int apiValue;
}
