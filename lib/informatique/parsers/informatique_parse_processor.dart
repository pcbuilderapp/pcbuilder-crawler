import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class InformatiqueProcessorParser implements PageWorker{

  parse(Document document, arguments) async {

    List caseUnits = [];
    String brand = arguments as String;
    var rows = document.querySelectorAll("div.title");
    for (Element listRow in rows) {
      Product processor = new Product();
      processor.name = listRow.querySelector("a").text.trim();
      processor.brand = brand;
      processor.url = listRow.querySelector("a").attributes["href"];
      processor.type = "CPU";
      processor.shop = "Informatique";
      await Crawler.crawl(processor.url, new InformatiqueCaseDetailParser(), arguments: processor);

      caseUnits.add(processor);
    }
    return caseUnits;
  }
}

class InformatiqueCaseDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product processor = arguments as Product;

    processor.price = price("");

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    processor.ean = dataFlix.attributes["data-flix-ean"];
    processor.mpn = dataFlix.attributes["data-flix-mpn"];

    String cpuSocket = "";
    var techDataTableElements = document.querySelectorAll("div.productShort ul li");
    for (int i = 0; i < techDataTableElements.length; i++) {

      List<String> productShort = techDataTableElements[i].text.split(":");

      String techDataLabel = productShort[0];
      String techData = productShort[1];

      if (techDataLabel == "Socket") {
        cpuSocket = techData;
      }

    }
    processor.connectors.add(new Connector(cpuSocket, "CPU"));
    String productJSON = new JsonEncoder.withIndent("  ").convert(processor);
    postRequest(getBackendServerURL()+"/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}