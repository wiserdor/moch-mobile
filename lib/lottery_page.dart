import 'package:flutter/material.dart';

import 'lottery_builder.dart';
import 'lottery_checker.dart';

class LotteryPage extends StatefulWidget {
  const LotteryPage({Key? key}) : super(key: key);

  @override
  _LotteryPageState createState() => _LotteryPageState();
}

class _LotteryPageState extends State<LotteryPage> {
  final LotteryChecker lotteryChecker = LotteryChecker();
  List<dynamic>? lotteryList;

  String dropdownValue = 'order';

  Future<void> _loadHistory({sortParameter = 'order'}) async {
    var history = await lotteryChecker.loadHistory();
    lotteryList = history.values.map((e) => e.last).toList();
    //sort by order
    if (sortParameter == 'timestamp') {
      lotteryList?.sort((a, b) => b[sortParameter].compareTo(a[sortParameter]));
    } else {
      lotteryList?.sort((a, b) => a[sortParameter].compareTo(b[sortParameter]));
    }
    // remove order less than 1
    lotteryList?.removeWhere((element) => element[sortParameter] < 1);
    setState(() {}); // trigger UI update
  }

  void _sort(String? sortParameter) {
    if (sortParameter != null) {
      setState(() {
        dropdownValue = sortParameter;
        _loadHistory(sortParameter: sortParameter);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: lotteryList == null || lotteryList!.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: lotteryList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    // last data by id
                    var data = lotteryList?[index];
                    // if null return empty container
                    if (data == null) return const SizedBox.shrink();

                    return LotteryDetails(data: data);
                  },
                )),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          alignment: Alignment.center,
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: _sort,
          items: <Map<String, String>>[
            {'value': 'timestamp', 'label': 'עדכון אחרון'},
            {'value': 'order', 'label': 'מיקום זכיה'},
            {'value': 'resident_order', 'label': 'מיקום זכיה תושב העיר'}
          ].map<DropdownMenuItem<String>>((Map<String, String> value) {
            return DropdownMenuItem<String>(
              value: value['value'],
              alignment: Alignment.centerRight,
              child: Text(value['label']!, textDirection: TextDirection.rtl),
            );
          }).toList(),
        ),
        const SizedBox(width: 24),
        Text('מיין לפי:', textDirection: TextDirection.rtl),
      ])
    ]);
  }
}
