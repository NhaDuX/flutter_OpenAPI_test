import 'package:flutter/material.dart';

import 'package:flutter_api/app/data/api.dart';
import 'package:flutter_api/app/model/category.dart';
import 'package:flutter_api/app/model/product.dart';
import 'package:flutter_api/mainpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductAdd extends StatefulWidget {
  final bool isUpdate;
  final ProductModel? productModel;

  const ProductAdd({super.key, this.isUpdate = false, this.productModel});

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  String? selectedCate;
  List<CategoryModel> categorys = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _desController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imgController = TextEditingController();
  final TextEditingController _catIdController = TextEditingController();
  String titleText = "";

  Future<void> _onSave() async {
    final name = _nameController.text;
    final des = _desController.text;
    final price = double.parse(_priceController.text);
    final img = _imgController.text;
    final catId = _catIdController.text;
    var pref = await SharedPreferences.getInstance();
    bool success = await APIRepository().addProduct(
        ProductModel(
            id: 0,
            name: name,
            imageUrl: img,
            categoryId: int.parse(catId),
            categoryName: '',
            price: price,
            description: des),
        pref.getString('token').toString());
    if (success) {
      setState(() {});
    }
    Navigator.pop(context);
  }

  //reload Pro
  reloadPro() async {
    var pref = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    void pro = await APIRepository().getProduct(
        pref.getString('accountID').toString(),
        pref.getString('token').toString());
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Mainpage(initialIndex: 3),
        ));
    setState(() {});
  }

  Future<void> _onUpdate() async {
    final name = _nameController.text;
    final des = _desController.text;
    final price = double.parse(_priceController.text);
    final img = _imgController.text;
    final catId = _catIdController.text;
    var pref = await SharedPreferences.getInstance();
    //update
    await APIRepository().updateProduct(
        ProductModel(
            id: widget.productModel!.id,
            name: name,
            imageUrl: img,
            categoryId: int.parse(catId),
            categoryName: '',
            price: price,
            description: des),
        pref.getString('accountID').toString(),
        pref.getString('token').toString());
    setState(() {});
    Navigator.pop(context);
  }

  _getCategorys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var temp = await APIRepository().getCategory(
        prefs.getString('accountID').toString(),
        prefs.getString('token').toString());
    setState(() {
      selectedCate = temp.first.id.toString();
      _catIdController.text = selectedCate.toString();
      categorys = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCategorys();

    if (widget.productModel != null && widget.isUpdate) {
      _nameController.text = widget.productModel!.name;
      _desController.text = widget.productModel!.description;
      _priceController.text = widget.productModel!.price.toString();
      _imgController.text = widget.productModel!.imageUrl;
      _catIdController.text = widget.productModel!.categoryId.toString();
    }
    if (widget.isUpdate) {
      titleText = "Update Product";
    } else {
      titleText = "Add New Product";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: Text(titleText),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Infomations:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Price',
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 10),
              TextField(
                controller: _imgController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Image URL',
                  //hintText: 'Enter imageURL',
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 10),
              TextField(
                controller: _desController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Desciption',
                  //hintText: 'Enter description',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Category:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 50, color: Colors.white))),
                value: selectedCate,
                items: categorys
                    .map((item) => DropdownMenuItem<String>(
                          value: item.id.toString(),
                          child: Text(item.name,
                              style: const TextStyle(fontSize: 20)),
                        ))
                    .toList(),
                //onChanged: (item) => setState(() => selectedCate = item),
                onChanged: (item) {
                  // final selectedCategoryId = int.tryParse(item ?? '');
                  setState(() {
                    selectedCate = item;
                    _catIdController.text = item.toString();
                    print(_catIdController.text);
                  });
                },
              ),
              //image
              const SizedBox(height: 16.0),
              const SizedBox(height: 20),
              SizedBox(
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.isUpdate) {
                      _onUpdate();
                      //reloadPro();
                    } else {
                      _onSave();
                      //reloadPro();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
