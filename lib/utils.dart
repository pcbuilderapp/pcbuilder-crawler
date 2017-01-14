import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:io';
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

  if (product.connectors.length > 0) {
    postRequest(backendServerUrl + addProductUrl, jsonEncoder.convert(product));

  } else {
    print("Product " + product.name + " does not have any components and will not be posted to the backend.");
  }
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