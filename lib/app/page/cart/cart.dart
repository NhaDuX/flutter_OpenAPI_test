import 'package:flutter/material.dart';
import 'package:flutter_api/app/data/api.dart';
import 'package:flutter_api/app/data/sqlite.dart';
import 'package:flutter_api/app/model/cart.dart';
import 'package:flutter_api/mainpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Cart>> _getProducts() async {
    return await _databaseHelper.products();
  }

  int _totalQuantity = 0;
  double _totalPrice = 0.0;

  void _calculateTotals(List<Cart> products) {
    _totalQuantity = products.fold(0, (sum, item) => sum + item.count);
    _totalPrice =
        products.fold(0, (sum, item) => sum + (item.price * item.count));
  }

  void _updateCart() async {
    var products = await _getProducts();
    setState(() {
      _calculateTotals(products);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateCart();
  }

  Future<void> _clearCart() async {
    await _databaseHelper.clear();
    _updateCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: const Text("Cart"),
        actions: [
          const Text("Delete All"),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteAllDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(10)),
          Expanded(
            child: FutureBuilder<List<Cart>>(
              future: _getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData) {
                  _calculateTotals(snapshot.data!);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final itemProduct = snapshot.data![index];
                      return _buildProduct(itemProduct, context);
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No products in the cart.'),
                  );
                }
              },
            ),
          ),
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildProduct(Cart pro, BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(pro.img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pro.name,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        NumberFormat('#,##0' + ' VND').format(pro.price),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 94, 93, 93),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    DatabaseHelper().minus(pro);
                    _updateCart();
                  },
                  icon: const Icon(
                    Icons.remove,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    controller:
                        TextEditingController(text: pro.count.toString()),
                    onChanged: (value) {
                      setState(() {
                        pro.count = int.tryParse(value) ?? pro.count;
                        _updateCart();
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    DatabaseHelper().add(pro);
                    _updateCart();
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                _showDeleteDialog(context, pro);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Cart pro) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Bạn có muốn xoá sản phẩm không?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  DatabaseHelper().deleteProduct(pro.productID);
                  _updateCart();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete All'),
          content: const Text(
              'Bạn có muốn xoá tất cả sản phẩm trong giỏ hàng không?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete All'),
              onPressed: () {
                _clearCart();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF5F6FA),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số lượng: $_totalQuantity cái',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tổng: ${NumberFormat('#,##0').format(_totalPrice)} VNĐ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                List<Cart> temp = await _databaseHelper.products();
                await APIRepository()
                    .addBill(temp, pref.getString('token').toString());
                _databaseHelper.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Mainpage(initialIndex: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Payment",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
