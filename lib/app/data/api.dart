import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_api/app/model/bill.dart';
import 'package:flutter_api/app/model/cart.dart';
import 'package:flutter_api/app/model/category.dart';
import 'package:flutter_api/app/model/product.dart';
import 'package:flutter_api/app/model/register.dart';
import 'package:flutter_api/app/model/user.admin.dart';
import 'package:flutter_api/app/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  final Dio _dio = Dio();
  String baseUrl = "https://huflit.id.vn:4321";

  API() {
    _dio.options.baseUrl = "$baseUrl/api";
  }

  Dio get sendRequest => _dio;
}

class APIRepository {
  API api = API();

  Map<String, dynamic> header(String token) {
    return {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer $token'
    };
  }

  Future<String> register(Signup user) async {
    try {
      final body = FormData.fromMap({
        "numberID": user.numberID,
        "accountID": user.accountID,
        "fullName": user.fullName,
        "phoneNumber": user.phoneNumber,
        "imageURL": user.imageUrl,
        "birthDay": user.birthDay,
        "gender": user.gender,
        "schoolYear": user.schoolYear,
        "schoolKey": user.schoolKey,
        "password": user.password,
        "confirmPassword": user.confirmPassword
      });
      Response res = await api.sendRequest.post('/Student/signUp',
          options: Options(headers: header('no token')), data: body);
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "signup fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> login(String accountID, String password) async {
    try {
      final body =
          FormData.fromMap({'AccountID': accountID, 'Password': password});
      Response res = await api.sendRequest.post('/Auth/login',
          options: Options(headers: header('no token')), data: body);
      if (res.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final tokenData = res.data['data']['token'];
        print("ok login");
        prefs.setString('token', tokenData);
        prefs.setString('accountID', accountID);
        return tokenData;
      } else {
        return "login fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<User> current(String token) async {
    try {
      Response res = await api.sendRequest
          .get('/Auth/current', options: Options(headers: header(token)));
      return User.fromJson(res.data);
    } catch (ex) {
      rethrow;
    }
  }

  Future<List<UserA>> fetchUsers() async {
    try {
      Response response = await api.sendRequest.get('/WWAdmin/listUser');
      //print('API Response: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['data'] != null && response.data['data'] is List) {
          List<UserA> users = (response.data['data'] as List)
              .map((json) => UserA.fromJson(json))
              .toList();
          return users;
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load users');
    }
  }

  Future<List<UserA>> findByNumberID(String numberID) async {
    try {
      Response response = await api.sendRequest.get(
        '/WWAdmin/findByNumberID',
        queryParameters: {'accountID': numberID},
      );
      print('Search API Response: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map) {
          // Nếu phản hồi là một đối tượng duy nhất, chuyển đổi nó thành một danh sách chứa một phần tử
          return [UserA.fromJson(response.data)];
        } else if (response.data['data'] != null &&
            response.data['data'] is List) {
          // Nếu phản hồi là một danh sách
          List<UserA> users = (response.data['data'] as List)
              .map((json) => UserA.fromJson(json))
              .toList();
          return users;
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to find users');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to find users');
    }
  }

  Future<bool> removeUser(String accountID, String token) async {
    try {
      // Log thông tin yêu cầu gửi đi
      print('Sending request to remove user with accountID: $accountID');

      Response res = await api.sendRequest.delete(
        '/WWAdmin/removeUser',
        options: Options(headers: header(token)),
        queryParameters: {
          'accountID': accountID
        }, // Hoặc sử dụng data: {'accountID': accountID}
      );

      // Log thông tin phản hồi từ máy chủ
      print('Response status code: ${res.statusCode}');
      print('Response data: ${res.data}');

      return res.statusCode == 200;
    } catch (ex) {
      print('Error removing user: $ex');
      throw Exception('Failed to remove user');
    }
  }

  Future<String> updateProfile({
    required String numberID,
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String birthDay,
    required String schoolYear,
    required String schoolKey,
    String? imageURL,
  }) async {
    try {
      final body = FormData.fromMap({
        "NumberID": numberID,
        "FullName": fullName,
        "PhoneNumber": phoneNumber,
        "Gender": gender,
        "BirthDay": birthDay,
        "SchoolYear": schoolYear,
        "SchoolKey": schoolKey,
        if (imageURL != null) "ImageURL": imageURL,
      });

      Response res = await api.sendRequest.put('/Auth/updateProfile',
          options: Options(
              headers: header(
                  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiMDkyNjkyNzE2NCIsIklEIjoiMjFESDExNDM2NyIsImp0aSI6IjRhNDhmNWU0LWFjMzctNDNmMS1iNWRkLTc0MWMxZGY2MDk0MiIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlN0dWRlbnQiLCJleHAiOjE3Mjg0NTg4Mzd9.PTtYKEq38THK1mGgaR3WXIkgu4vSJ2fdfgUazdaOkAc")),
          data: body);
      if (res.statusCode == 200) {
        print("Cập nhật thành công");
        return "Cập nhật thành công";
      } else {
        print("Cập nhật không thành công");
        return "Cập nhật không thành công";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategory(
      String accountID, String token) async {
    try {
      Response res = await api.sendRequest.get(
          '/Category/getList?accountID=$accountID',
          options: Options(headers: header(token)));
      return res.data
          .map((e) => CategoryModel.fromJson(e))
          .cast<CategoryModel>()
          .toList();
    } catch (ex) {
      rethrow;
    }
  }

  Future<bool> addCategory(
      CategoryModel data, String accountID, String token) async {
    try {
      final body = FormData.fromMap({
        'name': data.name,
        'description': data.desc,
        'imageURL': data.imageUrl,
        'accountID': accountID
      });
      Response res = await api.sendRequest.post('/addCategory',
          options: Options(headers: header(token)), data: body);
      if (res.statusCode == 200) {
        print("ok add category");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> updateCategory(int categoryID, CategoryModel data,
      String accountID, String token) async {
    try {
      final body = FormData.fromMap({
        'id': categoryID,
        'name': data.name,
        'description': data.desc,
        'imageURL': data.imageUrl,
        'accountID': accountID
      });
      Response res = await api.sendRequest.put('/updateCategory',
          options: Options(headers: header(token)), data: body);
      if (res.statusCode == 200) {
        print("ok update category");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> removeCategory(
      int categoryID, String accountID, String token) async {
    try {
      final body =
          FormData.fromMap({'categoryID': categoryID, 'accountID': accountID});
      Response res = await api.sendRequest.delete('/removeCategory',
          options: Options(headers: header(token)), data: body);
      if (res.statusCode == 200) {
        print("ok remove category");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<ProductModel>> getProduct(String accountID, String token) async {
    try {
      Response res = await api.sendRequest.get(
          '/Product/getList?accountID=$accountID',
          options: Options(headers: header(token)));
      return res.data
          .map((e) => ProductModel.fromJson(e))
          .cast<ProductModel>()
          .toList();
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductAdmin(
      String accountID, String token) async {
    try {
      Response res = await api.sendRequest.get(
          '/Product/getListAdmin?accountID=$accountID',
          options: Options(headers: header(token)));
      return res.data
          .map((e) => ProductModel.fromJson(e))
          .cast<ProductModel>()
          .toList();
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> addProduct(ProductModel data, String token) async {
    try {
      final body = FormData.fromMap({
        'name': data.name,
        'description': data.description,
        'imageURL': data.imageUrl,
        'Price': data.price,
        'CategoryID': data.categoryId
      });
      Response res = await api.sendRequest.post('/addProduct',
          options: Options(headers: header(token)), data: body);
      if (res.statusCode == 200) {
        print("ok add product");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> updateProduct(
      ProductModel data, String accountID, String token) async {
    try {
      final body = FormData.fromMap({
        'id': data.id,
        'name': data.name,
        'description': data.description,
        'imageURL': data.imageUrl,
        'Price': data.price,
        'categoryID': data.categoryId,
        'accountID': accountID
      });
      Response res = await api.sendRequest.put('/updateProduct',
          options: Options(headers: header(token)), data: body);
      if (res.statusCode == 200) {
        print("ok update product");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> removeProduct(
      int productID, String accountID, String token) async {
    try {
      final body =
          FormData.fromMap({'productID': productID, 'accountID': accountID});
      Response res = await api.sendRequest.delete('/removeProduct',
          options: Options(headers: header(token)), data: body);
      if (res.statusCode == 200) {
        print("ok remove product");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> addBill(List<Cart> products, String token) async {
    var list = [];
    try {
      for (int i = 0; i < products.length; i++) {
        list.add({
          'productID': products[i].productID,
          'count': products[i].count,
        });
      }
      Response res = await api.sendRequest.post('/Order/addBill',
          options: Options(headers: header(token)), data: list);
      if (res.statusCode == 200) {
        print("add bill ok");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<BillModel>> getHistory(String token) async {
    try {
      Response res = await api.sendRequest
          .get('/Bill/getHistory', options: Options(headers: header(token)));
      return res.data
          .map((e) => BillModel.fromJson(e))
          .cast<BillModel>()
          .toList();
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<BillDetailModel>> getHistoryDetail(
      String billID, String token) async {
    try {
      Response res = await api.sendRequest.post('/Bill/getByID?billID=$billID',
          options: Options(headers: header(token)));
      return res.data
          .map((e) => BillDetailModel.fromJson(e))
          .cast<BillDetailModel>()
          .toList();
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> removeBill(String billID, String token) async {
    try {
      final body = FormData.fromMap({'billID': billID});
      Response res = await api.sendRequest.delete('/Bill/remove?billID=$billID',
          options: Options(headers: header(token)), data: body);
      if (res.statusCode == 200) {
        print("ok remove bill");
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }
}
