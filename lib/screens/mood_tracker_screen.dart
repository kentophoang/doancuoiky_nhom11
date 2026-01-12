import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_provider.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Theo dõi tâm trạng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Hôm nay bạn thấy thế nào?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _moodIcon(context, '🤩', 'Rất vui', 5, Colors.orange),
                _moodIcon(context, '🙂', 'Ổn', 4, Colors.green),
                _moodIcon(context, '😐', 'Bình thường', 3, Colors.blue),
                _moodIcon(context, '😔', 'Hơi buồn', 2, Colors.indigo),
                _moodIcon(context, '😫', 'Mệt mỏi', 1, Colors.red),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Biểu đồ cảm xúc của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: moodProvider.entries.isEmpty 
                ? const Center(child: Text('Chưa có dữ liệu'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: moodProvider.entries.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: Colors.teal,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: true, color: Colors.teal.withAlpha(25)),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodIcon(BuildContext context, String emoji, String label, int value, Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Provider.of<MoodProvider>(context, listen: false).addMood(label, value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã ghi nhận: $label')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
