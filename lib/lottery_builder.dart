import 'package:flutter/material.dart';

class LotteryDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const LotteryDetails({super.key, required this.data});

  TableRow _buildRow(String value, String title) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Text(
          '${data['city']} - #${data['id']}',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            _buildRow('מספר הגרלה', '${data['id']}'),
            _buildRow('מיקום זכיה', '${data['order']}'),
            _buildRow('מיקום זכיה כתושב העיר',
                '${data['resident_order'] > 0 ? data['resident_order'] : 'אין'}'),
            _buildRow('עיר', '${data['city']}'),
            _buildRow('דירות בהגרלה', '${data['total_apartments']}'),
            _buildRow(
                'תאריך הגרלה',
                data['lottery_date']
                        ?.split('T')[0]
                        .split('-')
                        .reversed
                        .join('-') ??
                    ''),
            _buildRow(
                'עדכון אחרון',
                DateTime.fromMicrosecondsSinceEpoch(data['timestamp'] * 1000)
                    .toLocal()
                    .toString()
                    .split(' ')[0]
                    .split('-')
                    .reversed
                    .join('-')),
          ],
        ),
      ]),
    );
  }
}
