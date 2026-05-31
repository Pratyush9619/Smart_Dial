import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/constants/services.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/models/user_logoutcheck_model.dart';

import '../routes/app_routes.dart';

class ApiService {
  var header = {
    "x-api-key": APIUrls.apiKey,
  };

  // Method for GET requests
  Future<http.Response> getRequest(String endpoint) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final companyName = shared.get("companyname");
    final response = await http.get(
      Uri.parse(
          "${companyName == null ? APIUrls.baseUrl : "${APIUrls.newBaseUrl}$companyName/api/index.php/"}$endpoint"),
      headers: {
        "x-api-key": APIUrls.apiKey,
      },
    );

    print(
        "full url -->>> ${companyName == null ? APIUrls.baseUrl : "${APIUrls.newBaseUrl}$companyName/api/index.php/"}$endpoint");

    return response;
  }

  // Method for POST requests
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data,
      {String? type}) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final companyName = shared.get("companyname");

    final url = type == "reset"
        ? "${APIUrls.baseUrl}$endpoint"
        : companyName == null
            ? "${APIUrls.baseUrl}$endpoint"
            : "${APIUrls.newBaseUrl}$companyName/api/index.php/$endpoint";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        'User-Agent': 'SmartDialApp/1.0',
        "x-api-key": type == "login"
            ? APIUrls.loginApiKey
            : type == "reset"
                ? APIUrls.loginApiKey
                : APIUrls.apiKey,
      },
      body: data,
    );

    print("full url -->>> $url");
    // logOutput(
    //     'full url -->>> ${APIUrls.newBaseUrl}$companyName/api/index.php/"}$endpoint")');
    // logOutput("status code of $endpoint ${response.statusCode}");
    // logOutput("response of $endpoint ${response.body}");
    return response;
  }

  // Method for Multipart POST requests (for file uploads)
  Future<dynamic> multipartPostRequest(String endpoint,
      Map<String, String> fields, File? file, String? fileFieldName) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final companyName = shared.get("companyname");
    // Uri.parse("${companyName==null?APIUrls.baseUrl:"${APIUrls.newBaseUrl}${companyName}api/index.php/"}/$endpoint"),

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "${companyName == null ? APIUrls.baseUrl : "${APIUrls.newBaseUrl}$companyName/api/index.php/"}$endpoint"));
    request.headers.addAll(header);

    // Add fields
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add file
    if (file != null) {
      var fileStream =
          await http.MultipartFile.fromPath(fileFieldName!, file.path);
      request.files.add(fileStream);
    }

    // Send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print("response of $endpoint is ${response.body}");

    return response;
  }

  // Method for PUT requests
  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final companyName = shared.get("companyname");
    final response = await http.put(
      Uri.parse(
          "${companyName == null ? APIUrls.baseUrl : "${APIUrls.newBaseUrl}$companyName/api/index.php/"}$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "Surplus_apikey@",
      },
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // Method for DELETE requests
  Future<dynamic> deleteRequest(String endpoint) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final companyName = shared.get("companyname");
    final response = await http.delete(
      Uri.parse(
          "${companyName == null ? APIUrls.baseUrl : "${APIUrls.newBaseUrl}$companyName/api/index.php/"}$endpoint"),
    );
    return _handleResponse(response);
  }

  // Handle common response and errors
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      logOutput(response.body);
      return response.body;
    } else {
      throw Exception(
          "Error: ${response.statusCode}, Message: ${response.body}");
    }
  }

  // Future<dynamic> checkUserStillLoggedIn() async {
  //   SharedPreferences shared = await SharedPreferences.getInstance();
  //   final tellecallerid = shared.getString("telecaller_id");
  //   var uri = Uri.parse(
  //       "https://smartdial.co.in/misadmin/api/index.php/Auth/useractivecheck");

  //   var request = http.MultipartRequest('POST', uri)
  //     ..headers.addAll({
  //       "X-API-KEY": "ftc_apikey@",
  //       // "Accept": "*/*",
  //       // "Connection": "keep-alive",
  //     })
  //     ..fields['telecaller_id'] = '$tellecallerid';

  //   var response = await request.send();

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     var body = await response.stream.bytesToString();
  //     var jsonBody = jsonDecode(body);

  //     UserLogoutCheckModel userLogoutCheckModel =
  //         UserLogoutCheckModel.fromJson(jsonBody);
  //     if (userLogoutCheckModel.status == "1") {
  //       print("true");

  //       return true;
  //     } else {
  //       print("false");
  //       return false;
  //     }
  //   } else {
  //     var body = await response.stream.bytesToString();
  //     throw Exception("Error: ${response.statusCode}, Message: $body");
  //   }
  // }

  Future<dynamic> checkUserStillLoggedIn() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final companyName = shared.get("companyname");

    // final tellecallerid = shared.getString("telecaller_id");

    var uri = Uri.parse(
        "${companyName == null ? APIUrls.baseUrl : "${APIUrls.newBaseUrl}$companyName/api/index.php/"}${APIUrls.logoutCheck}");

    //  "https://smartdial.co.in/misadmin/api/index.php/Auth/useractivecheck"
    // );

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        "X-API-KEY": "ftc_apikey@",
        "Content-Type": "application/json",
      })
      ..fields['telecaller_id'] = StaticStoredData.userId.toString();
    //StaticStoredData.userId;

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var body = await response.stream.bytesToString();
      var jsonBody = jsonDecode(body);

      UserLogoutCheckModel userLogoutCheckModel =
          UserLogoutCheckModel.fromJson(jsonBody);
      if (userLogoutCheckModel.status == "1") {
        print("true");
        return true;
      } else {
        print("false");
        return false;
      }
    } else if (response.statusCode == 204) {
      print("No content received");
      return false; // Or handle as appropriate
    } else {
      var body = await response.stream.bytesToString();
      throw Exception("Error: ${response.statusCode}, Message: $body");
    }
  }

  Future<dynamic> checkUserLoggedInOnAnotherDevice() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    final companyName = shared.get("companyname");

    StaticStoredData.deviceId = await Services.getDeviceId();

    // final tellecallerid = shared.getString("telecaller_id");
    var uri = Uri.parse(
        "${companyName == null ? APIUrls.baseUrl : "${APIUrls.newBaseUrl}$companyName/api/index.php/"}${APIUrls.checkOnAnotherDeviceLogin}");

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        "X-API-KEY": "ftc_apikey@",
        "Content-Type": "application/json",
      })
      // ..fields['telecaller_id'] = StaticStoredData.userId.toString();
      ..fields.addAll({
        'telecaller_id': StaticStoredData.userId.toString(),
        'usertoken': StaticStoredData.deviceId.toString()
      });
    //StaticStoredData.userId;

    var response = await request.send();

    if (response.statusCode == 401) {
      return true;
    } else if (response.statusCode == 204) {
      print("No content received");
      return false; // Or handle as appropriate
    } else {
      var body = await response.stream.bytesToString();
      throw Exception("Error: ${response.statusCode}, Message: $body");
    }
  }
}
