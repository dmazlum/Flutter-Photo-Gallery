import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'package:gallery/app/utils/Auth.dart';
import 'package:gallery/app/models/mainCategories.dart';
import 'package:gallery/app/models/subCategories.dart';

class NetworkUtils {
//Method Authenticate User from Backed
  static dynamic authenticateUser(String username, String password) async {
    var _apiValue = getApiInfo(AuthUtils.endPoint);

    try {
      final response = await http.post(
        _apiValue["uri"],
        headers: {
          'x-api-key': _apiValue['apikey'],
          'authorization': basicAuthorizationHeader(
            _apiValue['_authUsername'],
            _apiValue['_authPassword'],
          ),
          'Accept': 'application/json',
        },
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == HttpStatus.ok) {
        final responseJson = json.decode(response.body);
        return responseJson;
      }
    } catch (exception) {
      print(exception);

      if (exception.toString().contains('SocketException')) {
        return 'NetworkError';
      } else {
        return false;
      }
    }
  }

// -------------
  static logoutUser(BuildContext context, SharedPreferences prefs) {
    prefs.setString(AuthUtils.authTokenKey, '');
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  static showSnackBar(
      GlobalKey<ScaffoldState> scaffoldKey, String message, int color) {
    scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(message ?? 'You are offline'),
        backgroundColor: Color(color),
      ),
    );
  }

  static checkConnectivity(key) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult != ConnectivityResult.mobile) &&
        (connectivityResult != ConnectivityResult.wifi)) {
      NetworkUtils.showSnackBar(
        key,
        "You are offline. Please connect to a network.",
        0xFFD50000,
      );
    }
  }
}

// Method to get main categories from the backend
Future<List<MainCategories>> getMainCategories() async {
  var _apiValue = getApiInfo('maincategories');

  var httpClient = new HttpClient();

  try {
    // Make the call
    var request = await httpClient.getUrl(Uri.parse(_apiValue['uri']));

    request.headers.add('x-api-key', _apiValue['apikey']);
    request.headers.add(
      'authorization',
      basicAuthorizationHeader(
        _apiValue['_authUsername'],
        _apiValue['_authPassword'],
      ),
    );
    var response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      var jsonResponse = await response.transform(utf8.decoder).join();

      // Decode the json response
      var data = jsonDecode(jsonResponse);

      // Get the result list
      List results = data["data"];

      // Get the Movie list
      List<MainCategories> mainCategoryList = createMainCategories(results);

      // Print the results.
      return mainCategoryList;
    } else {
      print("Failed http call.");
    }
  } catch (exception) {
    if (exception.toString().contains('SocketException')) {
      print("NetworkError");
    } else {
      print(exception.toString());
    }
  }
  return null;
}

/// Method to parse information from the retrieved data
List<MainCategories> createMainCategories(List data) {
  List<MainCategories> list = new List();

  for (int i = 0; i < data.length; i++) {
    var id = data[i]["id"];
    String sectionName = data[i]["section_name"];
    String sectionPhoto = data[i]["section_photo"];

    MainCategories mainCat = new MainCategories(id, sectionName, sectionPhoto);
    list.add(mainCat);
  }

  return list;
}

// Method to get sub categories from the backend
Future<SubCategories> getSubCategories(id, type) async {
  var _apiValue = getApiInfo('subcategories/id/' + id.toString());

  if (type == 'subname') {
    _apiValue = getApiInfo(
        'subcategories/id/' + id.toString() + '/type/subname/' + id.toString());
  }

  try {
    // Make the call
    final response = await http.get(
      _apiValue["uri"],
      headers: {
        'x-api-key': _apiValue['apikey'],
        'authorization': basicAuthorizationHeader(
          _apiValue['_authUsername'],
          _apiValue['_authPassword'],
        ),
      },
    );

    final responseJson = json.decode(response.body);

    // Get the SubCategory list
    SubCategories subCategoryList = createSubCategories(responseJson);

    // Print the results.
    return subCategoryList;
  } catch (exception) {
    if (exception.toString().contains('SocketException')) {
      print("NetworkError");
    } else {
      print(exception.toString());
    }
  }
  return null;
}

/// Method to parse information from the retrieved data
SubCategories createSubCategories(data) {
  List<SubCategoriesModel> subdataList = new List();
  List<Galleries> gallerydataList = new List();

  bool error = data["error"];
  var type = data["type"];
  var message = data["message"];
  var template = data["template"];
  var mainCategory = data["mainCategory"];
  var catName = data['catname'];

  if (!error) {
    var subdata = data["data"];

    if (subdata != null) {
      if (template == "categories") {
        for (int i = 0; i < subdata.length; i++) {
          var id = subdata[i]["id"];
          var subId = subdata[i]["sub_category_id"];
          String sectionName = subdata[i]["section_name"];
          String sectionPhoto = subdata[i]["section_photo"];

          SubCategoriesModel subCat = new SubCategoriesModel(
            id,
            subId,
            sectionName,
            sectionPhoto,
          );

          subdataList.add(subCat);
        }
      } else {
        for (int i = 0; i < subdata.length; i++) {
          var id = subdata[i]["id"];
          var galleryId = subdata[i]["gallery_id"];
          String photoName = subdata[i]["photo_name"];

          Galleries subCat = new Galleries(
            id,
            galleryId,
            photoName,
          );

          gallerydataList.add(subCat);
        }
      }
    }
  }

  SubCategories detail = new SubCategories(
    error,
    message,
    type,
    template,
    subdataList,
    gallerydataList,
    mainCategory,
    catName,
  );

  return detail;
}

getApiInfo(String addr) {
  String developmentHost = 'YOUR DEVELOPMENT HOST';
  String productionHost = 'YOUR PRODUCTION HOST';
  String host = developmentHost;

  var _apiInfo = {
    "productionHost": developmentHost,
    "developmentHost": productionHost,
    "host": host,
    "_authUsername": "admin",
    "_authPassword": "12345",
    "apikey": "APIKEY",
    "uri": host + addr
  };

  return _apiInfo;
}

// Basic Auth Creator
basicAuthorizationHeader(String username, String password) {
  return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
}
