import 'package:flutter/material.dart';
import 'package:flutter_api/app/data/api.dart';
import 'package:flutter_api/app/model/bill.dart';
import 'package:flutter_api/app/page/history/history_detail.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<BillModel>> _getBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await APIRepository()
        .getHistory(prefs.getString('token').toString());
  }

  Future<void> _refreshBills() async {
    setState(() {});
  }

  Future<void> _removeBill(String billID) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Order'),
          content: const Text('Bạn có muốn xoá đơn hàng này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // close the dialog
                SharedPreferences prefs = await SharedPreferences.getInstance();
                bool success = await APIRepository().removeBill(
                  billID,
                  prefs.getString('token').toString(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Bill  removed successfully'
                        : 'Failed to remove bill'),
                  ),
                );
                if (success) {
                  _refreshBills();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BillModel>>(
      future: _getBills(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final itemBill = snapshot.data![index];
              return Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  _billWidget(itemBill, context),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _billWidget(BillModel bill, BuildContext context) {
    return InkWell(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var temp = await APIRepository().getHistoryDetail(
            bill.id.toString(), prefs.getString('token').toString());
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HistoryDetail(
                    bill: temp,
                    billID: bill.id,
                  )),
        );
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Người mua: ' + bill.fullName,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                NumberFormat('Tổng tiền: ' + '#,##0' + ' VND')
                    .format(bill.total),
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 116, 110, 110),
                ),
              ),
              const SizedBox(height: 4.0),
              Text('Ngày mua: ${bill.dateCreated}'),
              const SizedBox(height: 0.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _removeBill(bill.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
