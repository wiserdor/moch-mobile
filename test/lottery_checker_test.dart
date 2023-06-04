// test checkLottery
import 'package:flutter_test/flutter_test.dart';
import 'package:moch_mobile/lottery_checker.dart';

var history = {
  "2301": [
    {
      "timestamp": 1685800276453,
      "order": 11733,
      "resident_order": 0,
      "city": "באר יעקב",
      "total_apartments": 42,
      "lottery_date": "2023-05-15T14:35:04.617",
      "id": "2301"
    }
  ],
  "2300": [
    {
      "timestamp": 1685800276453,
      "order": 30113,
      "resident_order": 0,
      "city": "באר יעקב",
      "total_apartments": 56,
      "lottery_date": "2023-05-15T14:14:17.19",
      "id": "2300"
    }
  ]
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // NEW

  test('checkLottery', () async {});
}
