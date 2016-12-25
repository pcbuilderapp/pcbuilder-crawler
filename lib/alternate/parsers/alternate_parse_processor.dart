import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class AlternateProcessorParser implements PageWorker {

  parse(Document document, arguments) async {

    List caseUnits = [];
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Product processor = new Product();
      processor.name = listRow.querySelector("span.name").text.trim();
      processor.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      processor.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      processor.type = "CPU";
      processor.price = price(listRow.querySelector("span.price").text);
      processor.shop = "Alternate";
      await Crawler.crawl(processor.url, new AlternateCaseDetailParser(), arguments: processor);

      caseUnits.add(processor);
    }
    return caseUnits;
  }
}

class AlternateCaseDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product product = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    product.ean = dataFlix.attributes["data-flix-ean"];
    product.mpn = dataFlix.attributes["data-flix-mpn"];

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
    product.connectors.add(new Connector(cpuSocket, "CPU"));
    String productJSON = new JsonEncoder.withIndent("  ").convert(product);
    postRequest(getBackendServerURL()+"/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}