import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class AlternateMemoryParser implements PageWorker {

  parse(Document document, arguments) async {

    List memoryUnits = [];
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Product memory = new Product();
      memory.name = listRow.querySelector("span.name").text.trim();
      memory.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      memory.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      memory.type = "MEM";
      memory.price = price(listRow.querySelector("span.price").text);
      memory.shop = "Alternate";
      await Crawler.crawl(memory.url, new AlternateMemoryDetailParser(), arguments: memory);
      if (memory.connectors.length > 0 ) {
        memoryUnits.add(memory);
      }
    }
    return memoryUnits;
  }
}

class AlternateMemoryDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product product = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    product.ean = dataFlix.attributes["data-flix-ean"];
    product.mpn = dataFlix.attributes["data-flix-mpn"];

    String memType = "";
    String memForm = "";
    var techDataTableElements = document.querySelectorAll("div.techData table tr");
    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataLabel = techDataTableElements[i].querySelector("td.c1").text.trim();
      String techData = techDataTableElements[i].querySelector("td.c4").text.trim();
      if (techDataLabel == "Standaard") {
        memType = techData.split(" ")[0];
      } else if (techDataLabel == "Bouwvorm") {
        memForm = techData.trim();
      }
    }
    if (memForm != "SO-DIMM") {
      product.connectors.add(new Connector(memType, "MEM"));

      String productJSON = new JsonEncoder.withIndent("  ").convert(product);
      postRequest(getBackendServerURL() + "/product/add", productJSON);
      print(productJSON);
      await sleepRnd();
    }
  }
}