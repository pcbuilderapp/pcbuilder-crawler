import "package:http/http.dart" as http;
import "dart:convert";
import "dart:math";
import "dart:async";
import "dart:io";
import "package:pcbuilder.crawler/model/connector.dart";
export "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/model/shop.dart";
import "package:pcbuilder.crawler/model/product.dart";
export "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/crawler.dart";
import "package:pcbuilder.crawler/config.dart";
export "package:pcbuilder.crawler/config.dart";
import "package:pcbuilder.crawler/urlcrawler.dart";
export "package:pcbuilder.crawler/urlcrawler.dart";
import "serializer.dart";

JsonEncoder jsonEncoder = new JsonEncoder.withIndent("  ");

///sleep a random amount of time without invoking a lock
Future sleepRnd() {
  Completer c = new Completer();
  new Timer(
      new Duration(
          milliseconds: (new Random().nextDouble() * 300 + 200).round()), () {
    c.complete();
  });
  return c.future;
}

///create a new Shop in the backend
void createShop(String name, String url) {
  postRequest((config["backendServerUrl"] ?? "/backend/") + config["createShopUrl"],
      jsonEncoder.convert(new Shop(name, url, "")));
}

///delete (tip) in the productdetail
String removeTip(String productName) {
  return productName.replaceAll("(tip)", "");
}

///convert price from String to double
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

///create headers for HTTP calls to look like a browser
Map getHTTPHeaders(String url, {String referrer, Map<String, String> cookies}) {
  Map headers = {};
  headers["Host"] = Uri.parse(url).host;
  headers["Cache-Control"] = "max-age=0";
  headers["Upgrade-Insecure-Requests"] = "1";
  headers["User-Agent"] =
      "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36";
  headers["Accept"] =
      "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8";
  if (referrer != null) headers["Referer"] = referrer;
  headers["Accept-Encoding"] = "gzip, deflate, sdch, br";
  headers["Accept-Language"] =
      "nl-NL,nl;q=0.8,en-US;q=0.6,en;q=0.4,de-DE;q=0.2";
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

///check if product has valid amount of connectors
bool checkConnectors(Product product) {
  if (product == null || product.connectors == null) {
    return false;
  }
  switch (product.type) {
    case 'CPU':
    case 'GPU':
    case 'STORAGE':
    case 'CASE':
    case 'PSU':
    case 'MEMORY':
      if (product.connectors.length > 0) {
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
        if (connector.type == 'CPU') {
          hasCPU = true;
        }
        if (connector.type == 'GPU') {
          hasGPU = true;
        }
        if (connector.type == 'STORAGE') {
          hasSTORAGE = true;
        }
        if (connector.type == 'CASE') {
          hasCASE = true;
        }
        if (connector.type == 'PSU') {
          hasPSU = true;
        }
        if (connector.type == 'MEMORY') {
          hasMEMORY = true;
        }
      }

      if (hasCPU && hasGPU && hasSTORAGE && hasCASE && hasPSU && hasMEMORY) {
        return true;
      }
      return false;

    default:
      return false;
  }
}

///Check if for every connector if the name is in the white list
void validateConnectors(Product product) {
  List<Connector> rejectedList = new List();

  for (Connector connector in product.connectors) {
    switch (connector.type) {
      case 'STORAGE':
        //checkIfExistInWhiteList(product);
        bool saveConnector = false;
        for (String allowedDisk in config["whiteListDisks"]) {
          if (connector.name.contains(allowedDisk)) {
            connector.name = allowedDisk;
            saveConnector = true;
            break;
          }
        }

        if (!saveConnector) {
          rejectedList.add(connector);
        }
        break;

      case 'GPU':
        //checkIfExistInWhiteList(product);
        bool saveConnector = false;
        for (String allowedGpu in config["whiteListGpu"]) {
          if (connector.name.contains(allowedGpu)) {
            connector.name = allowedGpu;
            saveConnector = true;
            break;
          }
        }
        if (!saveConnector) {
          rejectedList.add(connector);
        }
        break;

      case 'MEMORY':
        //checkIfExistInWhiteList(product);
        bool saveConnector = false;
        for (String allowedMemory in config["whiteListMemory"]) {
          if (connector.name.contains(allowedMemory)) {
            connector.name = allowedMemory;
            saveConnector = true;
            break;
          }
        }
        if (!saveConnector) {
          rejectedList.add(connector);
        }
        break;

      default:
        break;
    }
  }
  rejectedList.forEach((connector) => product.connectors.remove(connector));
}

/// Extend case types with extra connectors
void extendCaseType(String caseConnector, Product computerCase) {
  if (caseConnector != null) {
    if (caseConnector == "HPTX") {
      computerCase.connectors.add(new Connector("HPTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("XL-ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("SSI-EEB", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("E-ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("SSI-CEB", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("µATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("DTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else if (caseConnector == "XL-ATX") {
      computerCase.connectors.add(new Connector("XL-ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("SSI-EEB", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("E-ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("SSI-CEB", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("µATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("DTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else if (caseConnector == "E-ATX" || caseConnector == "SSI-EEB") {
      computerCase.connectors.add(new Connector("SSI-EEB", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("E-ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("SSI-CEB", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("µATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("DTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else if (caseConnector == "SSI-CEB") {
      computerCase.connectors.add(new Connector("SSI-CEB", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("µATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("DTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else if (caseConnector == "ATX") {
      computerCase.connectors.add(new Connector("ATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("µATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("DTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else if (caseConnector == "µATX") {
      computerCase.connectors.add(new Connector("µATX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("DTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else if (caseConnector == "DTX") {
      computerCase.connectors.add(new Connector("DTX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else if (caseConnector == "mITX" || caseConnector == "Mini-ITX") {
      computerCase.connectors.add(new Connector("mITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("Mini-ITX", config["computerCaseType"]));
      computerCase.connectors.add(new Connector("mATX", config["computerCaseType"]));
    } else {
      computerCase.connectors
          .add(new Connector(caseConnector.trim(), config["computerCaseType"]));
    }
  }
}

///Checks if listrow contains discount indication and sets anyProduct.discounted to true for Alternate
void setProductDiscountAlternate(Element listRow, Product anyProduct) {
  if(listRow.querySelector("div.strikedPrice") != null){
    anyProduct.discounted = true;
  } else {
    anyProduct.discounted = false;
  }
}

///Checks if listrow contains discount indication and sets anyProduct.discounted to true for Informatique
void setProductDiscountInformatique(Document document, Product anyProduct) {
  if(document.querySelector("p.price_old") != null){
    anyProduct.discounted = true;
  } else {
    anyProduct.discounted = false;
  }
}

///add a Product to the backend
postProduct(Product product) async {

  validateConnectors(product);
  String json = jsonEncoder.convert(product);

  if (checkConnectors(product)) {
    await postRequest((config["backendServerUrl"] ?? "/backend/") + config["addProductUrl"], json);
  } else {
/*    print("Product " +
        product.name +
        " does not have any components and will not be posted to the backend.\n" +
        json);*/
  }
  /*await sleepRnd();*/
}

///post data on a REST service URL and print the response
postRequest(String url, String json) async {
  if (config["printProducts"]) {
    print(json);
  }

  var request = new http.Request('POST', Uri.parse(url));
  request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json; charset=utf-8';
  request.body = json;

  if (config["waitForBackend"]) {
    var response = await new http.Client().send(request);
    response.stream
        .bytesToString()
        .then((value) => print(value.toString()))
        .catchError((error) => print(error.toString()));
  } else {
    new http.Client()
        .send(request)
        .catchError((error) => print(error.toString()));
  }
}

/// Checks on the backend if a Crawler is activated
Future<bool> isCrawlerActivated(String name) async {

  var response;
  String url = (config["backendServerUrl"] ?? "/backend/") + config["crawlerInfoUrl"] + name;

  try {
    var request = await new http.Request ("GET", Uri.parse(url));
    request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json; charset=utf-8';

    response = await new http.Client().send(request);

  } catch (e) {
    print(e);
    return false;
  }

  String rep = await response.stream.bytesToString();

  Crawler crawler = fromJson(rep, new Crawler());

  if (!crawler.activated) {
    print(config["crawlerNotLaunching"].toString().replaceFirst(new RegExp("NAME"), name));
  } else {
    print(config["crawlerLaunching"].toString().replaceFirst(new RegExp("NAME"), name));
  }

  return crawler.activated;
}
