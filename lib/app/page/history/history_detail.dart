import 'package:flutter/material.dart';
import 'package:flutter_api/app/model/bill.dart';

class HistoryDetail extends StatelessWidget {
  final List<BillDetailModel> bill;

  const HistoryDetail({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: bill.length,
        itemBuilder: (context, index) {
          var data = bill[index];
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(data.productName),
                Text(data.imageUrl),
                Text(data.price.toString()),
                Text(data.total.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
