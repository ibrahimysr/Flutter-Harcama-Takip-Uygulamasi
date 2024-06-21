import 'package:expense_tracker/bar_graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int starMonth; // 0 ocak 1 şubat 2 mart
  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.starMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = List.generate(widget.monthlySummary.length,
        (index) => IndividualBar(x: index, y: widget.monthlySummary[index]));
  }
  

  double calculateMax() { 
  double max = 500; 

  widget.monthlySummary.sort();

  max = widget.monthlySummary.last * 1.05;

  if(max < 500) {
    return 500;
  }
  return max;
  }


  @override
  Widget build(BuildContext context) {
    initializeBarData();

    //bar dimension sizes
    double barWidth = 20;
    double spaceBetweenBar = 40;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SizedBox(
          width:
              barWidth * barData.length + spaceBetweenBar * (barData.length - 1),
          child: BarChart(BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: getBottomTitles,
                          reservedSize: 28))),
              barGroups: barData
                  .map(
                    (data) => BarChartGroupData(x: data.x, barRods: [
                      BarChartRodData(
                          toY: data.y,
                          width: 20, // genişlik verme grafiğe ,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade700,
                          backDrawRodData: BackgroundBarChartRodData(
                              show: true, toY: calculateMax(), color: Colors.white)),
                    ]),
                  )
                  .toList(), 
                  alignment: BarChartAlignment.center, 
                  groupsSpace: spaceBetweenBar
                  )),
        ),
      ),
    );
  }
  //Bottom - tıtles
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const textstyle =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);

  String text;
  switch (value.toInt() % 12 + 1) {
    case 0:
      text = "Ocak";
      break;
    case 1:
      text = "Şubat";
      break;
    case 2:
      text = "Mart";
      break;
    case 3:
      text = "Nisan";
      break;
    case 4:
      text = "Mayıs";
      break;
    case 5:
      text = "Haziran";
      break;
    case 6:
      text = "Temmuz";
      break;
    case 7:
      text = "Ağustos";
      break;
    case 8:
      text = "Eylül";
      break;
    case 9:
      text = "Ekim";
      break;
    case 10:
      text = "Kasım";
      break;
    case 11:
      text = "Aralık";
      break;
    default:
      text = "";
      break;
  }
  return SideTitleWidget(
      child: Text(
        text,
        style: textstyle,
      ),
      axisSide: meta.axisSide);
}
