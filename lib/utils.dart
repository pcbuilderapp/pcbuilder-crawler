import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:pcbuilder.crawler/model/connector.dart';
import "package:pcbuilder.crawler/model/shop.dart";
import "package:pcbuilder.crawler/model/product.dart";
import 'package:pcbuilder.crawler/configuration.dart';

JsonEncoder jsonEncoder = new JsonEncoder.withIndent("  ");

///sleep a random amount of time without invoking a lock///
Future sleepRnd() {
  Completer c = new Completer();
  new Timer(new Duration(milliseconds: (new Random().nextDouble() * 300 + 200).round()),(){
    c.complete();
  });
  return c.future;
}

///create a new Shop in the backend///
void createShop(String name, String url) {
  postRequest(backendServerUrl + createShopUrl,
      jsonEncoder.convert(new Shop(name, url, "")));
}

///delete (tip) in the productdetail
String removeTip(String productName) {
    return productName.replaceAll("(tip)", "");
}

///convert price from String to double///
double price(String price) {
  List<int> temp = [];
  for (int codeUnit in price.codeUnits) {
    if (codeUnit >= 48 && codeUnit <= 57) {
      temp.add(codeUnit);
    } else if (codeUnit == 44) {
      temp.add(46);
    } else if (codeUnit == 45) {
      temp.add(48);
    }
  }
  return double.parse(new String.fromCharCodes(temp));
}

///create headers for HTTP calls to look like a browser///
Map getHTTPHeaders(String url, {String referrer, Map<String,String> cookies}) {
  Map headers = {};
  headers["Host"] = Uri.parse(url).host;
  headers["Cache-Control"] = "max-age=0";
  headers["Upgrade-Insecure-Requests"] = "1";
  headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36";
  headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8";
  if (referrer != null) headers["Referer"] = referrer;
  headers["Accept-Encoding"] = "gzip, deflate, sdch, br";
  headers["Accept-Language"] = "nl-NL,nl;q=0.8,en-US;q=0.6,en;q=0.4,de-DE;q=0.2";
  if (cookies != null) {
    String cookiesstr = "";
    for (String key in cookies.keys) {
      cookiesstr += "$key=\"${cookies[key]}\";";
    }
    headers["Cookie"] = cookiesstr;
  }
  headers["DNT"] = "1";
  return headers;
}

///add a Product to the backend///
void postProduct(Product product) {
  validateConnectors(product);
  if (checkConnectors(product)) {
    postRequest(backendServerUrl + addProductUrl, jsonEncoder.convert(product));
  } else {
    print("Product " + product.name + " has invalid amount of components and will not be posted to the backend.");
  }
}

bool checkConnectors(Product product) {
  if(product == null || product.connectors == null){
      return false;
  }

    switch (product.type) {
      case 'CPU':
      case 'GPU':
      case 'STORAGE':
      case 'CASE':
      case 'PSU':
      case 'MEMORY':
      if(product.connectors.length > 0) {
        return true;
      }
      return false;
      case 'MOTHERBOARD':
        bool hasCPU = false;
        bool hasGPU = false;
        bool hasSTORAGE = false;
        bool hasCASE = false;
        bool hasPSU = false;
        bool hasMEMORY = false;

        for (Connector connector in product.connectors) {
          if(connector.type == 'CPU'){
            hasCPU = true;
          }
          if(connector.type == 'GPU'){
            hasGPU = true;
          }
          if(connector.type == 'STORAGE'){
            hasSTORAGE = true;
          }
          if(connector.type == 'CASE'){
            hasCASE = true;
          }
          if(connector.type == 'PSU'){
            hasPSU = true;
          }
          if(connector.type == 'MEMORY'){
            hasMEMORY = true;
          }
        }
        if(hasCPU && hasGPU && hasSTORAGE && hasCASE && hasPSU && hasMEMORY){
          return true;
        }
        return false;
      default:
        break;

  }
}

void validateConnectors(Product product){
  List<Connector> rejectedList = new List();
  for (Connector connector in product.connectors) {
    switch (connector.type) {
      case 'STORAGE':
      //checkIfExistInWhiteList(product);
      bool saveConnector = false;
        for (String allowedDisk in whiteListDisks) {
          if(connector.name.contains(allowedDisk)){
            connector.name = allowedDisk;
            saveConnector = true;
            break;
          }
        }
        if (!saveConnector){
          rejectedList.add(connector);
        }
        break;
      case 'GPU':
      //checkIfExistInWhiteList(product);
        bool saveConnector = false;
        for (String allowedGpu in whiteListGpu) {
          if(connector.name.contains(allowedGpu)){
            connector.name = allowedGpu;
            saveConnector = true;
            break;
          }
        }
        if (!saveConnector){
          rejectedList.add(connector);
        }
        break;
      case 'MEMORY':
      //checkIfExistInWhiteList(product);
        bool saveConnector = false;
        for (String allowedMemory in whiteListMemory) {
          if(connector.name.contains(allowedMemory)){
            connector.name = allowedMemory;
            saveConnector = true;
            break;
          }
        }
        if (!saveConnector){
          rejectedList.add(connector);
        }
        break;
      default:
        break;
    }
  }
  rejectedList.forEach((connector) => product.connectors.remove(connector));
}

/// post data on a REST service URL and print the response///
void postRequest(String url, String json) {

    if (printProducts) {
      print(json);
    }

    var request = new http.Request('POST', Uri.parse(url));
    request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json; charset=utf-8';
    request.body = json;

    new http.Client().send(request).then((response) =>
        response.stream.bytesToString().then((value) => print(value.toString())))
        .catchError((error) => print(error.toString()));
}