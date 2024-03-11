import 'package:flutter/material.dart';

import 'lottery_details.dart';
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
  bool isLoading = false;

  Future<void> _loadHistory({sortParameter = 'order'}) async {
    setState(() {
      isLoading = true;
    });

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

    setState(() {
      isLoading = false;
    });
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              ListTile(
                title: const Center(child: Text('עדכון אחרון')),
                onTap: () {
                  _sort('timestamp');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Center(child: Text('מיקום זכיה')),
                onTap: () {
                  _sort('order');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Center(child: Text('מיקום זכיה תושב העיר')),
                onTap: () {
                  _sort('resident_order');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (lotteryList != null && lotteryList!.isNotEmpty)
                  ListView.builder(
                    itemCount: lotteryList!.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = lotteryList?[index];
                      if (data == null) return const SizedBox.shrink();

                      return LotteryDetails(data: data);
                    },
                  ),
                if (isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 40, top: 32),
        child: Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton(
            onPressed: isLoading ? null : _showSortOptions,
            tooltip: 'מיון לפי',
            backgroundColor: Color(0xff99C2A2),
            child: const Icon(
              Icons.sort,
            ),
          ),
        ),
      ),
    );
  }
}
