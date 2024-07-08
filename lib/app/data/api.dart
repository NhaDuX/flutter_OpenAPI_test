import '/app/model/register.dart';
import '/app/model/user.dart';
import 'package:dio/dio.dart';

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
        final tokenData = res.data['data']['token'];
        print("ok login");
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

  Future<String> updateProfile({
    //required String token,
    required String numberID,
    required String fullName,
    required String phoneNumber,
    //required String gender,
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
        "Gender": "2",
        "BirthDay": birthDay,
        "SchoolYear": schoolYear,
        "SchoolKey": schoolKey,
        if (imageURL != null) "ImageURL": imageURL,
      });

      Response res = await api.sendRequest.put('/Auth/updateProfile',
          options: Options(
              headers: header(
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiMDkyNjkyNzE2NCIsIklEIjoiMjFESDExNDM2NyIsImp0aSI6IjhhZjhlNDJiLTlhYmYtNDIzYS1hNDEwLTU1OWU1ZjQ2ZDFmYSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlN0dWRlbnQiLCJleHAiOjE3MjgyMzE3MTl9.-zLLIv1SIEa8_0UQweLehAzSdQUTlS5JodB-amAO4lI')),
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
}
