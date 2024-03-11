import 'package:flutter/material.dart';

class LotteryDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const LotteryDetails({super.key, required this.data});

  TableRow _buildRow(String value, String title) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              value,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Color(0xFFf2f6fd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              data['city'],
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildRow('${data['id']}', 'מספר הגרלה'),
                _buildRow(
                    data['lottery_date']
                            ?.split('T')[0]
                            .split('-')
                            .reversed
                            .join('/') ??
                        '',
                    'תאריך הגרלה'),
                _buildRow('${data['order']}', 'מיקום זכיה'),
                _buildRow(
                    '${data['resident_order'] > 0 ? data['resident_order'] : 'אין'}',
                    'מיקום זכיה כתושב העיר'),
                _buildRow('${data['city']}', 'עיר'),
                _buildRow('${data['total_apartments']}', 'דירות בהגרלה'),
                _buildRow(
                    DateTime.fromMicrosecondsSinceEpoch(
                            data['timestamp'] * 1000)
                        .toLocal()
                        .toString()
                        .split(' ')[0]
                        .split('-')
                        .reversed
                        .join('/'),
                    'עדכון אחרון'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
